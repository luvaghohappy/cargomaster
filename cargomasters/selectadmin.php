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
$password = $data->passwords;

// Requête SQL pour vérifier les identifiants
$rqt = "SELECT * FROM administrateur WHERE email = '$email' AND passwords = '$password' LIMIT 1";
$rqt2 = mysqli_query($connect, $rqt);

if (!$rqt2) {
    $response = array("status" => "error", "message" => "Erreur d'exécution de la requête: " . mysqli_error($connect));
} elseif (mysqli_num_rows($rqt2) > 0) {
    $response = array("status" => "success", "message" => "Authentification réussie");
} else {
    $response = array("status" => "error", "message" => "Email ou mot de passe incorrect");
}

echo json_encode($response);
?>
