<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'error.log');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: *");
header('Content-Type: application/json');

include('conn.php');
mysqli_set_charset($connect, "utf8");

// Log de connexion
if (!$connect) {
    error_log("Erreur de connexion : " . mysqli_connect_error());
    echo json_encode(["error" => "Problème de connexion à la base de données"]);
    exit;
} else {
    error_log("Connexion réussie à la base de données.");
}

if (!isset($_GET['chauffeur_id'])) {
    echo json_encode(["error" => "Chauffeur ID manquant"]);
    exit;
}

$chauffeur_id = intval($_GET['chauffeur_id']);

// 🔹 Nouvelle requête SQL avec JOIN
$sql = "SELECT l.livraison_id, l.chauffeur_id, l.date_depart, l.date_arrivee_prevue, 
               ST_AsGeoJSON(l.itineraire) AS itineraire, l.statut, l.colis_id, l.statut_colis, e.etat
        FROM livraisons l
        LEFT JOIN expeditions e ON l.livraison_id = e.livraison_id
        WHERE l.chauffeur_id = ? 
        ORDER BY l.date_depart DESC";

// Log de la requête SQL
error_log("Requête SQL préparée : " . $sql);

$stmt = $connect->prepare($sql);

// Log si la préparation échoue
if ($stmt === false) {
    error_log("Erreur SQL : " . $connect->error);
    echo json_encode(["error" => "Erreur de préparation SQL"]);
    exit;
} else {
    error_log("Requête SQL préparée avec succès.");
}

$stmt->bind_param("i", $chauffeur_id);

if ($stmt->execute()) {
    $result = $stmt->get_result();
    $livraisons = $result->fetch_all(MYSQLI_ASSOC);

    // Log des données récupérées
    error_log("Données livraisons : " . print_r($livraisons, true));

    $json_response = json_encode(["status" => "success", "livraisons" => $livraisons ?: []]);

    if ($json_response === false) {
        error_log("Erreur json_encode : " . json_last_error_msg());
        die(json_encode(["error" => "Échec de json_encode()", "details" => json_last_error_msg()]));
    }

    echo $json_response;
} else {
    error_log("Erreur exécution SQL : " . $stmt->error);
    echo json_encode(["error" => "Erreur d'exécution SQL"]);
}

$stmt->close();
$connect->close();
?>
