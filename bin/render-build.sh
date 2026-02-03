#!/usr/bin/env bash
# Render.com ビルドスクリプト
# RememberIt - 暗記・暗唱学習プラットフォーム
#
# このスクリプトはRender.comでのデプロイ時に実行されます
# 参照: https://render.com/docs/deploy-rails

set -o errexit  # エラー時に即座に終了

echo "=== RememberIt ビルド開始 ==="

# Bundlerの設定
echo ">>> Bundlerを設定中..."
bundle config set --local deployment 'true'
bundle config set --local without 'development test'

# Gem のインストール
echo ">>> Gem をインストール中..."
bundle install

# JavaScript依存関係のインストール（Node.jsがある場合）
if command -v node &> /dev/null; then
  echo ">>> Node.js パッケージをインストール中..."
  npm install || yarn install || true
fi

# アセットのプリコンパイル
echo ">>> アセットをプリコンパイル中..."
bundle exec rails assets:precompile

# アセットのクリーンアップ（古いアセットを削除）
echo ">>> 古いアセットをクリーンアップ中..."
bundle exec rails assets:clean

# データベースマイグレーション
# 初回デプロイ時はdb:prepareを使用（DBが存在しない場合は作成）
echo ">>> データベースをマイグレーション中..."
bundle exec rails db:prepare

# Solid Queue/Solid Cacheのマイグレーション（使用している場合）
echo ">>> Solid Queue/Cache のセットアップ..."
bundle exec rails solid_queue:install:migrations || true
bundle exec rails solid_cache:install:migrations || true
bundle exec rails db:migrate

echo "=== RememberIt ビルド完了 ==="
