<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
// Inclusion du fichier connect.php qui contient la connexion à la base de données
include('conn.php');

// Récupérer les données envoyées depuis Flutter
$nom = isset($_POST['noms']) ? $_POST['noms'] : '';
$type = isset($_POST['types']) ? $_POST['types'] : '';
$email = isset($_POST['email']) ? $_POST['email'] : '';
$telephone = isset($_POST['telephone']) ? $_POST['telephone'] : '';
$password = htmlspecialchars($_POST["passwords"]);
$vehicule_id = isset($_POST['vehicule_id']) ? $_POST['vehicule_id'] : '';

// Vérification des champs
if (empty($nom) || empty($type) || empty($email) || empty($telephone) || empty($password) || empty($vehicule_id)) {
    echo json_encode(["status" => "error", "message" => "Tous les champs sont obligatoires."]);
    exit;
}

$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Préparer la requête pour insérer le chauffeur
$query = "INSERT INTO chauffeurs (noms, types, email, telephone, passwords, vehicule_id) VALUES (?, ?, ?, ?, ?, ?)";

// Préparer la déclaration
if ($stmt = $connect->prepare($query)) {
    // Lier les paramètres
    $stmt->bind_param("ssssss", $nom, $type, $email, $telephone, $hashedPassword, $vehicule_id);

    // Exécuter la requête
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Chauffeur ajouté avec succès."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Erreur lors de l'ajout du chauffeur."]);
    }

    // Fermer la déclaration
    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Erreur de préparation de la requête."]);
}

// Fermer la connexion à la base de données
$connect->close();
?>
