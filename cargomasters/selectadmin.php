<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: *");
header('Content-Type: application/json');

include('conn.php');

error_reporting(E_ALL);
ini_set('display_errors', 1);

// Récupérer les données JSON du corps de la requête
$data = json_decode(file_get_contents("php://input"));

$email = $data->email;
$password = $data->passwords; // Mot de passe en texte brut saisi par l'utilisateur

// Vérifier si l'email existe
$rqt = "SELECT passwords FROM administrateur WHERE email = ?";
$stmt = mysqli_prepare($connect, $rqt);
mysqli_stmt_bind_param($stmt, "s", $email);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if ($row = mysqli_fetch_assoc($result)) {
    $hashed_password = $row['passwords']; // Récupération du hash en base de données

    if (password_verify($password, $hashed_password)) {
        // Authentification réussie
        $response = array("success" => true, "message" => "Authentification réussie");
    } else {
        // Mauvais mot de passe
        $response = array("success" => false, "message" => "Email ou mot de passe incorrect");
    }
} else {
    // Aucun compte trouvé avec cet email
    $response = array("success" => false, "message" => "Email ou mot de passe incorrect");
}

echo json_encode($response);
?>
