<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

include('conn.php');

// Récupération des données envoyées
$data = json_decode(file_get_contents('php://input'), true);
error_log("🔍 Requête reçue : " . json_encode($data));

if (!isset($data['livraison_id'], $data['etat'])) {
    error_log("❌ Données manquantes");
    echo json_encode(["status" => "error", "message" => "Données manquantes"]);
    exit;
}

$livraison_id = intval($data['livraison_id']);
$etat = $data['etat'];

$allowed_states = ['En route', 'Livrée', 'Retardée'];
if (!in_array($etat, $allowed_states)) {
    error_log("❌ État invalide : $etat");
    echo json_encode(["status" => "error", "message" => "État invalide"]);
    exit;
}

// Vérifier si la livraison existe
$checkQuery = "SELECT COUNT(*) FROM expeditions WHERE livraison_id = ?";
$checkStmt = $conn->prepare($checkQuery);
$checkStmt->bind_param('i', $livraison_id);
$checkStmt->execute();
$checkStmt->bind_result($count);
$checkStmt->fetch();
$checkStmt->close();

if ($count == 0) {
    error_log("❌ Livraison ID $livraison_id non trouvée.");
    echo json_encode(["status" => "error", "message" => "Livraison introuvable"]);
    exit;
}

// Mettre à jour le statut de la livraison
$updateQuery = "UPDATE expeditions SET etat = ? WHERE livraison_id = ?";
$stmt = $connect->prepare($updateQuery);
if ($stmt === false) {
    error_log("❌ Erreur de préparation SQL : " . $connect->error);
    echo json_encode(["status" => "error", "message" => "Erreur SQL : " . $connect->error]);
    exit;
}

$stmt->bind_param('si', $etat, $livraison_id);

if ($stmt->execute()) {
    error_log("✅ Statut mis à jour pour livraison ID $livraison_id en $etat.");
    echo json_encode(["status" => "success", "message" => "Statut mis à jour"]);
} else {
    error_log("❌ Erreur lors de la mise à jour SQL : " . $stmt->error);
    echo json_encode(["status" => "error", "message" => "Erreur lors de la mise à jour"]);
}

$stmt->close();
$connect->close();
?>
