<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

include('conn.php');

// Récupération des données envoyées via POST
$data = json_decode(file_get_contents('php://input'), true);

// Vérification des données
if (!isset($data['livraison_id'], $data['etat'])) {
    echo json_encode(["status" => "error", "message" => "Données manquantes"]);
    exit;
}

$livraison_id = $data['livraison_id'];
$etat = $data['etat'];

// Liste des états autorisés
$allowed_states = ['En route', 'Livrée', 'Retardée'];

// Vérification que l'état est valide
if (!in_array($etat, $allowed_states)) {
    echo json_encode(["status" => "error", "message" => "État invalide"]);
    exit;
}

// Vérification de l'existence de la livraison
$checkQuery = "SELECT COUNT(*) FROM expeditions WHERE livraison_id = ?";
$stmt = $connect->prepare($checkQuery);
$stmt->bind_param('i', $livraison_id);
$stmt->execute();
$stmt->bind_result($count);
$stmt->fetch();
$stmt->close();

if ($count == 0) {
    echo json_encode(["status" => "error", "message" => "Livraison introuvable"]);
    exit;
}

// Mise à jour de l'état de la livraison
$updateQuery = "UPDATE expeditions SET etat = ? WHERE livraison_id = ?";
$stmt = $connect->prepare($updateQuery);
$stmt->bind_param('si', $etat, $livraison_id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Statut mis à jour avec succès"]);
} else {
    echo json_encode(["status" => "error", "message" => "Erreur lors de la mise à jour du statut"]);
}

$stmt->close();
$connect->close();
?>
