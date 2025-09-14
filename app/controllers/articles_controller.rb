# app/controllers/articles_controller.rb

require "httparty"
require "nokogiri"
require "openai"

class ArticlesController < ApplicationController
  # トップページ（入力フォームと結果一覧）
  def index
    @articles = Article.all.order(created_at: :desc)
  end

  # スクレイピングとAI分析の実行
  def create
    url = params[:url]
    unless url.start_with?("https://www3.nhk.or.jp/news/html/")
      redirect_to root_path, alert: "無効なURLです。NHKニュースの記事URLを入力してください。"
      return
    end

    begin
      # --- 1. スクレイピング処理 ---
      response = HTTParty.get(url, headers: { "User-Agent" => "Mozilla/5.0" })
      doc = Nokogiri::HTML(response.body)

      title = doc.css("h1.content--title").text.strip
      body = doc.css(".content--detail-main").text.strip.gsub(/\s+/, " ") # 空白文字を整形
      published_at_str = doc.css("time.content--date").attr("datetime")&.value
      published_at = Time.parse(published_at_str) if published_at_str.present?

      if title.blank? || body.blank?
        raise "記事のタイトルまたは本文の取得に失敗しました。"
      end

      # --- 2. OpenAI APIによる分析 ---
      client = OpenAI::Client.new
      prompt = <<~PROMPT
        以下のニュース記事を分析し、JSON形式でリスクスコアと要約を生成してください。

        # 指示
        - リスクスコアは、記事に記載されている事件や事故の「被害範囲」「被害程度」「社会的影響」「死傷者の有無や人数、被害金額の大きさ」を総合的に判断し、1から100の整数で評価してください。スコアが高いほど社会にとって高リスクな事案です。
        - 要約は、記事の要点を1文で簡潔にまとめてください。

        # ニュース記事本文
        #{body}

        # 出力形式 (必ずこのJSONフォーマットで返してください)
        {
          "risk_score": <Integer>,
          "summary": "<String>"
        }
      PROMPT

      response = client.chat(
        parameters: {
          model: "gpt-4o", # 最新モデルを推奨
          messages: [ { role: "user", content: prompt } ],
          temperature: 0.2,
          response_format: { type: "json_object" }
        }
      )

      ai_response = JSON.parse(response.dig("choices", 0, "message", "content"))

      # --- 3. データベースへの保存 ---
      Article.create!(
        title: title,
        body: body,
        published_at: published_at,
        source_url: url,
        risk_score: ai_response["risk_score"],
        summary: ai_response["summary"]
      )

      redirect_to root_path, notice: "記事の分析が完了しました。"

    rescue => e
      # エラーが発生した場合
      redirect_to root_path, alert: "エラーが発生しました: #{e.message}"
    end
  end
end
