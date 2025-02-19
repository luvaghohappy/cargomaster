<?php 
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

include('conn.php'); // Database connection

$chauffeur_id = isset($_POST['chauffeur_id']) ? intval($_POST['chauffeur_id']) : 0;
$colis_id = isset($_POST['colis_id']) ? intval($_POST['colis_id']) : 0;
$date_depart = isset($_POST['date_depart']) ? $_POST['date_depart'] : '';
$date_arrivee_prevue = isset($_POST['date_arrivee_prevue']) ? $_POST['date_arrivee_prevue'] : '';
$statut = isset($_POST['statut']) ? $_POST['statut'] : 'Planifiée';
$statut_colis = isset($_POST['statut_colis']) ? $_POST['statut_colis'] : 'Prêt à être livré';
$itineraire = isset($_POST['itineraire']) ? $_POST['itineraire'] : '';

// Check if the colis_id already exists
$check_query = "SELECT * FROM livraisons WHERE colis_id = ?";
$check_stmt = $connect->prepare($check_query);
$check_stmt->bind_param("i", $colis_id);
$check_stmt->execute();
$check_result = $check_stmt->get_result();

if ($check_result->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "Ce colis est déjà enregistré dans une livraison."]);
    exit;
}

// Extract latitude and longitude from itineraire
$coords = explode(",", $itineraire);
if (count($coords) != 2) {
    echo json_encode(["status" => "error", "message" => "Format de l'itinéraire invalide."]);
    exit;
}

$latitude = floatval(trim($coords[0]));
$longitude = floatval(trim($coords[1]));

if ($latitude == 0 || $longitude == 0) {
    echo json_encode(["status" => "error", "message" => "Latitude ou longitude incorrecte."]);
    exit;
}

// Insert new delivery
$point = "POINT($longitude $latitude)";
$query = "INSERT INTO livraisons (chauffeur_id, colis_id, date_depart, date_arrivee_prevue, statut_colis, itineraire) 
          VALUES (?, ?, ?, ?, ?, ?, ST_GeomFromText(?))";

if ($stmt = $connect->prepare($query)) {
    $stmt->bind_param("iisssss", $chauffeur_id, $colis_id, $date_depart, $date_arrivee_prevue, $statut, $statut_colis, $point);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Livraison ajoutée avec succès."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Erreur lors de l'ajout : " . $stmt->error]);
    }
    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Erreur de préparation de la requête."]);
}

$connect->close();
?>
