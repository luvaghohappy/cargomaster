<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

// Récupération des données du formulaire, en les protégeant contre les attaques XSS
$nom = mysqli_real_escape_string($connect, htmlspecialchars($_POST["noms"]));
$adresse = mysqli_real_escape_string($connect, htmlspecialchars($_POST["adresse"]));
$telephone = mysqli_real_escape_string($connect, htmlspecialchars($_POST["telephone"]));
$email = mysqli_real_escape_string($connect, htmlspecialchars($_POST["email"]));

// Debugging information
error_log("noms: $nom");
error_log("adresse: $adresse");
error_log("telephone: $telephone");
error_log("email: $email");

// Requête SQL pour insérer les données dans la table 'formations'
$sql = "INSERT INTO clients (noms, adresse, telephone, email) VALUES ('$nom', '$adresse', '$telephone', '$email')";

if (mysqli_query($connect, $sql)) {
    echo json_encode("success");
} else {
    echo json_encode("failed: " . mysqli_error($connect));
}
?>
