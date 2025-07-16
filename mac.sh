#!/bin/bash

clear

echo "╔══════════════════════════════════════╗"
echo "║ 🌸 開発者: Devcode                  ║"
echo "║ ⚠️  本ツールは教育目的でのみ使用可能    ║"
echo "╚══════════════════════════════════════╝"

echo "📦 Homebrewと必要なパッケージをチェック中..."

if ! command -v brew > /dev/null; then
    echo "🛠 Homebrewが見つかりません、インストールします"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

for pkg in php cloudflared curl; do
    if ! brew list "$pkg" > /dev/null 2>&1; then
        echo "➕ $pkg をインストール中..."
        brew install "$pkg" > /dev/null
    else
        echo "✅ $pkg はすでにインストール済みです"
    fi
done

echo "🚀 PHPサーバーを起動中（ポート: 8080）..."
php -S localhost:8080 > /dev/null 2>&1 &
php_pid=$!
sleep 2

echo "🌐 Cloudflareトンネルを起動中..."
cloudflared tunnel --url http://localhost:8080 > .cf.log 2>&1 &
cf_pid=$!
sleep 5

url=$(grep -o 'https://[^ ]*\.trycloudflare\.com' .cf.log | head -n 1)
echo "✨ 発行URL: $url"

webhook_url=""
json="{\"content\": \"🔔 URLが発行されました\n$url\"}"
curl -H "Content-Type: application/json" -X POST -d "$json" "$webhook_url" > /dev/null 2>&1

trap 'echo \"🛑 停止中...\"; kill $php_pid $cf_pid; exit 0' SIGINT
wait
