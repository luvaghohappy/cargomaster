<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: *");
header('Content-Type: application/json');

include('conn.php');

// Activer le mode debug (à désactiver en production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Récupération des données JSON
$data = json_decode(file_get_contents("php://input"), true);

$email = htmlspecialchars($data["email"] ?? "");
$password = htmlspecialchars($data["passwords"] ?? "");

// Vérifier si l'email et le mot de passe sont fournis
if (empty($email) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Email et mot de passe requis"]);
    exit;
}

// Requête sécurisée avec requête préparée (évite SQL injection)
$stmt = $connect->prepare("SELECT passwords FROM chauffeurs WHERE email = ? LIMIT 1");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    
    // Vérification du mot de passe (Si stocké en hash bcrypt)
    if (password_verify($password, $user["passwords"])) {
        echo json_encode(["status" => "success", "message" => "Authentification réussie"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Mot de passe incorrect"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Aucun utilisateur trouvé avec cet email"]);
}

$stmt->close();
$connect->close();
?>
