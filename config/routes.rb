# config/routes.rb

Rails.application.routes.draw do
  # "/" にアクセスされたら、articlesコントローラーのindexアクションを呼ぶ
  root "articles#index"

  # 記事の作成（スクレイピング実行）のためのルート
  resources :articles, only: [ :index, :create ]
end
