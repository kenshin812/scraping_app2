gitに登録
```bash
git init
git add -A
git remote add origin https://~
```
git push
```bash
git push origin main
```
自身のフォルダをrailsアプリケーションにする
```bash
rails new . --force
```
Gemのインストール(Gemfileの変更後)
```bash
bundle install
```
サーバーの起動(EC2サーバーのアプリケーションディレクトリ内で)
```bash
nohup rails s &
```
サーバーの停止
```bash
# 1. プロセスを探す
ps aux | grep puma

# 2. 表示されたPID（数字）を使ってプロセスを終了させる
kill 12345  # 12345は表示されたPIDに置き換える
```