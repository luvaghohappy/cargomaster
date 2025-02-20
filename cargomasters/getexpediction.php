<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

include('conn.php'); 

// Requête SQL corrigée (suppression de la virgule en trop)
$rqt = "SELECT 
            livraison_id, 
            chauffeur_id,     
            etat,  
            ST_X(position_actuelle) AS latitude, 
            ST_Y(position_actuelle) AS longitude 
        FROM expeditions
        ORDER BY expedition_id DESC";

$rqt2 = mysqli_query($connect, $rqt) OR die(json_encode(["status" => "error", "message" => mysqli_error($connect)]));

$result = array();

while ($fetchData = $rqt2->fetch_assoc()) {
    $fetchData['position_actuelle'] = $fetchData['latitude'] . "," . $fetchData['longitude']; 
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
