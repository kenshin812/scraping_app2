# config/initializers/openai.rb

OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_API_KEY")
end
# ここで設定した内容は、Railsアプリケーション全体で利用可能になります。
