<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, PUT");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

include('conn.php');

$chauffeur_id = $_POST['chauffeur_id'];
$livraison_id = $_POST['livraison_id'];
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];

// Vérifier si une livraison avec ce ID existe déjà
$sql_check = "SELECT * FROM expeditions WHERE livraison_id = ?";
$stmt_check = $connect->prepare($sql_check);
$stmt_check->bind_param("i", $livraison_id);
$stmt_check->execute();
$result_check = $stmt_check->get_result();

if ($result_check->num_rows > 0) {
    // Si une expédition existe déjà pour cette livraison, on met à jour la position
    $sql_update = "UPDATE expeditions SET position_actuelle = POINT(?, ?) WHERE livraison_id = ?";
    $stmt_update = $connect->prepare($sql_update);
    $stmt_update->bind_param("dii", $latitude, $longitude, $livraison_id);
    if ($stmt_update->execute()) {
        echo "Position mise à jour avec succès.";
    } else {
        echo "Erreur lors de la mise à jour de la position.";
    }
} else {
    // Sinon, on insère une nouvelle expédition
    $sql_insert = "INSERT INTO expeditions (livraison_id, chauffeur_id, position_actuelle, etat) VALUES (?, ?, POINT(?, ?), 'En route')";
    $stmt_insert = $connect->prepare($sql_insert);
    $stmt_insert->bind_param("iidd", $livraison_id, $chauffeur_id, $latitude, $longitude);
    if ($stmt_insert->execute()) {
        echo "Expédition ajoutée avec succès.";
    } else {
        echo "Erreur lors de l'ajout de l'expédition.";
    }
}

$connect->close();
?>
