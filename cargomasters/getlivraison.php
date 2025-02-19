<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

include('conn.php'); 

// Requête SQL avec conversion de `itineraire` en latitude et longitude
$rqt = "SELECT 
            livraison_id, 
            vehicule_id, 
            chauffeur_id, 
            colis_id, 
            date_depart, 
            date_arrivee_prevue, 
            statut, 
            statut_colis,
            ST_X(itineraire) AS longitude, 
            ST_Y(itineraire) AS latitude
        FROM livraisons 
        ORDER BY livraison_id DESC";

$rqt2 = mysqli_query($connect, $rqt) OR die(json_encode(["status" => "error", "message" => mysqli_error($connect)]));

$result = array();

while ($fetchData = $rqt2->fetch_assoc()) {
    $fetchData['itineraire'] = $fetchData['latitude'] . "," . $fetchData['longitude']; 
    unset($fetchData['latitude'], $fetchData['longitude']); 
    $result[] = $fetchData;
}

// Vérification si la table est vide
if (empty($result)) {
    echo json_encode(["status" => "empty", "message" => "Aucune livraison trouvée."]);
} else {
    echo json_encode(["status" => "success", "data" => $result]);
}

mysqli_close($connect);
?>
