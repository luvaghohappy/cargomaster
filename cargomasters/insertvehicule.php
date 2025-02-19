<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

// Récupération des données du formulaire, en les protégeant contre les attaques XSS
$marque = mysqli_real_escape_string($connect, htmlspecialchars($_POST["marque"]));
$modele = mysqli_real_escape_string($connect, htmlspecialchars($_POST["modele"]));
$imm = mysqli_real_escape_string($connect, htmlspecialchars($_POST["immatriculation"]));

// Debugging information
error_log("marque: $marque");
error_log("modele: $modele");
error_log("immatriculation: $imm");

// Requête SQL pour insérer les données dans la table 'formations'
$sql = "INSERT INTO vehicules (marque, modele, immatriculation ) VALUES ('$marque','$modele', '$imm')";

if (mysqli_query($connect, $sql)) {
    echo json_encode("success");
} else {
    echo json_encode("failed: " . mysqli_error($connect));
}
?>
