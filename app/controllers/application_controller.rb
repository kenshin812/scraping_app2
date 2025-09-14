class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :basic_auth

  private

  # このメソッドを追加
  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      # credentialsからユーザー名とパスワードを読み込んで比較
      username == Rails.application.credentials.production[:basic_auth_username] &&
      password == Rails.application.credentials.production[:basic_auth_password]
    end
  end
end
