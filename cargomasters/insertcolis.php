<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

// Récupération des données du formulaire, en les protégeant contre les attaques XSS
$clientid = mysqli_real_escape_string($connect, htmlspecialchars($_POST["client_id"]));
$nom = mysqli_real_escape_string($connect, htmlspecialchars($_POST["noms_client"]));
$description = mysqli_real_escape_string($connect, htmlspecialchars($_POST["descriptions"]));
$poids = mysqli_real_escape_string($connect, htmlspecialchars($_POST["poids"]));
$adresse = mysqli_real_escape_string($connect, htmlspecialchars($_POST["adresse_livraison"]));

// Debugging information
error_log("client_id: $clientid");
error_log("noms_client: $nom");
error_log("descriptions: $description");
error_log("poids: $poids");
error_log("adresse_livraison: $adresse");

// Requête SQL pour insérer les données dans la table 'formations'
$sql = "INSERT INTO colis (client_id, noms_client, descriptions, poids, adresse_livraison) VALUES ('$clientid','$nom', '$description','$poids','$adresse')";

if (mysqli_query($connect, $sql)) {
    echo json_encode("success");
} else {
    echo json_encode("failed: " . mysqli_error($connect));
}
?>
