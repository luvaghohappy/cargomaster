<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

// Inclusion du fichier connect.php qui contient la connexion à la base de données
include('conn.php');

// Vérification de la méthode de la requête
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Data received via POST method
    
    $nom = htmlspecialchars($_POST["noms"]);
    $adresse = htmlspecialchars($_POST["adresse"]);
    $telephone = htmlspecialchars($_POST["telephone"]);
    $email = htmlspecialchars($_POST["email"]);
    $id = htmlspecialchars($_POST["client_id"]);

    // Requête SQL pour mettre à jour les données dans la table 'inscription'
    $sql = "UPDATE clients SET noms = '$nom', adresse ='$adresse',telephone ='$telephone', email ='$email'  WHERE client_id = '$id'";
    
    // Exécution de la requête SQL
    if (mysqli_query($connect, $sql)) {
        // Affichage d'un message en cas de réussite de la mise à jour
        echo "Mise à jour réussie.";
    } else {
        // Affichage d'un message d'erreur en cas d'échec de la mise à jour
        echo "Erreur lors de la mise à jour : " . $connect->error;
    }
} elseif ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Logic to fetch historical data
    // ...
} else {
    // Unsupported request method
    http_response_code(405); // Method Not Allowed
}
?>