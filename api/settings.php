<?php
require 'config.php';
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $stmt = $pdo->query("SELECT `key`,`value` FROM settings");
    $rows = $stmt->fetchAll();
    $out = [];
    foreach ($rows as $r) $out[$r['key']] = $r['value'];
    echo json_encode($out);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
if ($method === 'POST') {
    // {key: 'pomodoro_minutes', value: '25'}
    if (!isset($input['key'])) { http_response_code(400); echo json_encode(['error'=>'Missing key']); exit; }
    $value = isset($input['value']) ? $input['value'] : null;
    $stmt = $pdo->prepare('INSERT INTO settings (`key`,`value`) VALUES (:k,:v) ON DUPLICATE KEY UPDATE `value` = :v2');
    $stmt->execute([':k'=>$input['key'], ':v'=>$value, ':v2'=>$value]);
    echo json_encode(['ok'=>true]);
    exit;
}