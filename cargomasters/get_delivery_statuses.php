<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json");

// Inclusion du fichier de connexion à la base de données
include('conn.php');

// Requête SQL pour récupérer tous les statuts de livraison
$query = "SELECT livraison_id, etat FROM expeditions";

// Préparation de la requête
$stmt = $connect->prepare($query);
if ($stmt === false) {
    echo json_encode(["status" => "error", "message" => "Erreur lors de la préparation de la requête"]);
    exit;
}

// Exécution de la requête
$stmt->execute();

// Récupérer le résultat
$result = $stmt->get_result();

// Tableau pour stocker les livraisons
$livraisons = [];

while ($data = $result->fetch_assoc()) {
    $livraisons[] = $data;
}

// Si des livraisons existent, renvoyer le tableau des statuts
if (count($livraisons) > 0) {
    echo json_encode(["status" => "success", "livraisons" => $livraisons]);
} else {
    // Si aucune livraison n'est trouvée
    echo json_encode(["status" => "error", "message" => "Aucune livraison trouvée"]);
}

// Fermer la requête et la connexion
$stmt->close();
$connect->close();
?>
