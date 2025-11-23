<?php
require 'config.php';
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $stmt = $pdo->query('SELECT * FROM sessions ORDER BY started_at DESC');
    echo json_encode($stmt->fetchAll());
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
if ($method === 'POST') {
    // expected: subject_id (nullable), subject_name, duration_minutes, started_at
    if (!isset($input['duration_minutes']) || !isset($input['started_at'])) {
        http_response_code(400);
        echo json_encode(['error'=>'Missing fields']);
        exit;
    }
    $stmt = $pdo->prepare('INSERT INTO sessions (subject_id, subject_name, duration_minutes, started_at) VALUES (:sid, :sname, :dur, :start)');
    $stmt->execute([
        ':sid' => isset($input['subject_id']) ? $input['subject_id'] : null,
        ':sname' => isset($input['subject_name']) ? $input['subject_name'] : null,
        ':dur' => $input['duration_minutes'],
        ':start' => $input['started_at']
    ]);
    echo json_encode(['id' => $pdo->lastInsertId()]);
    exit;
}