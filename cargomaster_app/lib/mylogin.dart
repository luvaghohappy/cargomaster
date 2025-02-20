import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'const.dart';

class MyLogin extends StatefulWidget {
  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int _attempts = 0;
  bool _fieldsDisabled = false;

  Future<void> loginUser() async {
    if (_fieldsDisabled) return;

    final url = '${AppConstants.baseUrl}selectadmin.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': emailController.text,
          'passwords': passwordController.text,
        }),
      );

      print("Réponse du serveur : ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Données reçues : $responseData");

        if (responseData['success'] == true) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _attempts++;
          if (_attempts >= 3) {
            setState(() {
              _fieldsDisabled = true;
            });
            _showErrorDialog(context, 'Accès refusé après 3 tentatives.');
          } else {
            _showErrorDialog(
                context, responseData['message'] ?? 'Erreur inconnue.');
          }
        }
      } else {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la connexion : $e");
      _showErrorDialog(
          context, 'Erreur de connexion. Vérifiez votre connexion internet.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur de connexion'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Container en arrière-plan avec une image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                width: 650,
                height: 350,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Image à gauche
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.asset(
                          'assets/log.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                labelText: 'Mot de passe',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                            const SizedBox(height: 24.0),
                            GestureDetector(
                              onTap: loginUser,
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Connexion',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
