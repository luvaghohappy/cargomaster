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

if (!isset($_GET['chauffeur_id'])) {
    echo json_encode(["error" => "Chauffeur ID manquant"]);
    exit;
}

$chauffeur_id = intval($_GET['chauffeur_id']);

if (!$connect) {
    error_log("Erreur de connexion : " . mysqli_connect_error());
    echo json_encode(["error" => "Problème de connexion à la base de données"]);
    exit;
}

// 🔹 Convertir itineraire en GeoJSON
$sql = "SELECT livraison_id,chauffeur_id, date_depart, date_arrivee_prevue, 
               ST_AsGeoJSON(itineraire) AS itineraire, statut, colis_id, statut_colis
        FROM livraisons WHERE chauffeur_id = ? ORDER BY date_depart DESC";

$stmt = $connect->prepare($sql);

if ($stmt === false) {
    error_log("Erreur SQL : " . $connect->error);
    echo json_encode(["error" => "Erreur de préparation SQL"]);
    exit;
}

$stmt->bind_param("i", $chauffeur_id);

if ($stmt->execute()) {
    $result = $stmt->get_result();
    $livraisons = $result->fetch_all(MYSQLI_ASSOC);

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
