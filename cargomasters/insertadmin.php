<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
// Inclusion du fichier connect.php qui contient la connexion à la base de données
include('conn.php');

// Récupérer les données envoyées depuis Flutter
$email = isset($_POST['email']) ? $_POST['email'] : '';
$password = htmlspecialchars($_POST["passwords"]);

// Vérification des champs
if ( empty($email)  || empty($password) ) {
    echo json_encode(["status" => "error", "message" => "Tous les champs sont obligatoires."]);
    exit;
}

$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Préparer la requête pour insérer le chauffeur
$query = "INSERT INTO administrateur (email,passwords) VALUES (?, ?)";

// Préparer la déclaration
if ($stmt = $connect->prepare($query)) {
    // Lier les paramètres
    $stmt->bind_param("ss",$email, $hashedPassword);

    // Exécuter la requête
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Admin ajouté avec succès."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Erreur lors de l'ajout du Admin."]);
    }

    // Fermer la déclaration
    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Erreur de préparation de la requête."]);
}

// Fermer la connexion à la base de données
$connect->close();
?>
