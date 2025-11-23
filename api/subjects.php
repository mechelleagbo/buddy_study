<?php
require 'config.php';
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $stmt = $pdo->query('SELECT * FROM subjects ORDER BY created_at DESC');
    $rows = $stmt->fetchAll();
    echo json_encode($rows);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

if ($method === 'POST') {
    if (empty($input['name'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing name']);
        exit;
    }
    $stmt = $pdo->prepare('INSERT INTO subjects (name) VALUES (:name)');
    $stmt->execute([':name' => $input['name']]);
    echo json_encode(['id' => $pdo->lastInsertId(), 'name' => $input['name']]);
    exit;
}

if ($method === 'DELETE') {
    // Expect query param id
    if (!isset($_GET['id'])) { http_response_code(400); echo json_encode(['error'=>'Missing id']); exit; }
    $id = (int)$_GET['id'];
    $stmt = $pdo->prepare('DELETE FROM subjects WHERE id = :id');
    $stmt->execute([':id'=>$id]);
    echo json_encode(['deleted' => $id]);
    exit;
}