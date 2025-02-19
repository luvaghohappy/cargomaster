<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
// Inclusion du fichier connect.php qui contient la connexion à la base de données
include('conn.php');


    // Récupération de la valeur de 'id' et protection contre les attaques XSS
    $id = htmlspecialchars($_GET['client_id']);

    // Requête de suppression dans la table 'etudiants' où 'id' correspond à la valeur récupérée
    $sql = "DELETE FROM clients WHERE client_id = '" . $id . "'";
    
    // Exécution de la requête de suppression
    if (mysqli_query($connect,$sql)) {
        // Affichage d'un message en cas de réussite de la suppression
        echo "Suppression réussie.";
    } else {
        // Affichage d'un message d'erreur en cas d'échec de la suppression
        echo "Erreur lors de la suppression : " . $connect->error;
    }


?>