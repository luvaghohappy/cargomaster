import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart'; // Package pour obtenir la position actuelle
import 'const.dart';

class ChauffeurDashboard extends StatefulWidget {
  final Function(bool) onToggleTheme;
  final bool isDarkMode;

  const ChauffeurDashboard({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<ChauffeurDashboard> createState() => _ChauffeurDashboardState();
}

class _ChauffeurDashboardState extends State<ChauffeurDashboard> {
  List<Map<String, dynamic>> livraisonsList = [];
  List<bool> deliveredStatus = [];
  List<bool> delayedStatus = [];

  // Fonction pour obtenir la position actuelle
  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Services de localisation désactivés")),
      );
      return Future.error('Services de localisation désactivés');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permission refusée');
      }
    }

    // Retourne la position actuelle
    return await Geolocator.getCurrentPosition();
  }

  Future<void> fetchLivraisons() async {
    final chauffeurId = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt("chauffeur_id"));
    if (chauffeurId == null) {
      print("🚨 Erreur : Chauffeur ID non trouvé !");
      return;
    }

    final url = Uri.parse(
        "${AppConstants.baseUrl}selectlivraison.php?chauffeur_id=$chauffeurId");
    print("🔍 Requête envoyée : $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse["status"] == "success") {
          setState(() {
            livraisonsList =
                List<Map<String, dynamic>>.from(jsonResponse["livraisons"]);
            deliveredStatus =
                List.generate(livraisonsList.length, (index) => false);
            delayedStatus =
                List.generate(livraisonsList.length, (index) => false);
          });
        }
      } else {
        print("❌ Erreur: Réponse vide ou statut échoué");
      }
    } catch (e) {
      print("❌ Erreur lors de la récupération des livraisons : $e");
    }
  }

  void _moveToLocation(String location) async {
    try {
      final parsed = jsonDecode(location);
      final coordinates = parsed['coordinates'];
      final lat = coordinates[1];
      final lon = coordinates[0];

      // Récupérer la position actuelle du chauffeur
      Position position = await _getCurrentPosition();
      double currentLat = position.latitude;
      double currentLon = position.longitude;

      // Calculer l'itinéraire entre la position actuelle et la destination
      _openGoogleMaps(currentLat, currentLon, lat, lon);
    } catch (e) {
      print('❌ Erreur lors de la conversion des coordonnées: $e');
    }
  }

  Future<void> _openGoogleMaps(
      double startLat, double startLon, double endLat, double endLon) async {
    final googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLon&destination=$endLat,$endLon";

    try {
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir Google Maps")),
        );
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture de Google Maps: $e');
    }
  }

  Future<void> sendPosition(int livraisonId, int chauffeurId) async {
    // Demander la permission pour accéder à la position
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Les services de localisation sont désactivés.');
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Si la permission est refusée
      print('Permission de localisation refusée.');
      return;
    }

    // Obtenir la position actuelle
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // URL de ton API PHP pour insérer ou mettre à jour les données
    String url = '${AppConstants.baseUrl}update_position.php';

    // Préparer les données à envoyer
    Map<String, String> body = {
      'chauffeur_id': chauffeurId.toString(),
      'livraison_id': livraisonId.toString(),
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString(),
    };

    // Effectuer la requête POST
    final response = await http.post(Uri.parse(url), body: body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Expédition ajoutée avec succès',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    if (response.statusCode == 200) {
      print("Position envoyée avec succès !");
    } else {
      print("Erreur lors de l'envoi de la position.");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLivraisons();
    // _loadDeliveryStatuses();
  }

  Future<void> _updateStatus(int livraisonId, String etat) async {
    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}update_status.php"),
      body: {
        "livraison_id": livraisonId.toString(),
        "etat": etat,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Statut mis à jour en $etat"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la mise à jour du statut"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fonction pour charger l'état des livraisons
  Future<void> _loadDeliveryStatuses() async {
    final response = await http.get(
      Uri.parse("${AppConstants.baseUrl}get_delivery_statuses.php"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      for (var item in data['livraisons']) {
        int livraisonId = item['livraison_id'];
        String etat = item['etat'];

        setState(() {
          if (etat == 'Livrée') {
            deliveredStatus[livraisonId] = true;
            delayedStatus[livraisonId] = false;
          } else if (etat == 'Retardée') {
            delayedStatus[livraisonId] = true;
            deliveredStatus[livraisonId] = false;
          } else {
            deliveredStatus[livraisonId] = false;
            delayedStatus[livraisonId] = false;
          }
        });
      }
    } else {
      // Erreur dans la récupération des données
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors du chargement des statuts des livraisons"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Livraisons",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => widget.onToggleTheme(!widget.isDarkMode),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DataTable(
                  columnSpacing: 20.0,
                  headingRowColor:
                      MaterialStateProperty.all(Colors.deepOrange.shade100),
                  columns: const [
                    DataColumn(label: Text('ID Livraison')),
                    DataColumn(label: Text('Chauffeur')),
                    DataColumn(label: Text('Colis ID')),
                    DataColumn(label: Text('Date Départ')),
                    DataColumn(label: Text('Date Arrivée')),
                    DataColumn(label: Text('Itinéraire')),
                    DataColumn(label: Text('Statut Colis')),
                    DataColumn(label: Text("Partage Position")),
                    DataColumn(label: Text("Livrée")),
                    DataColumn(label: Text("Retardée")),
                  ],
                  rows: livraisonsList.asMap().entries.map((entry) {
                    int index = entry.key;
                    var livraison = entry.value;

                    return DataRow(cells: [
                      DataCell(
                        Text(
                          livraison['livraison_id'].toString(),
                        ),
                      ),
                      DataCell(
                        Text(
                          livraison['chauffeur_id'].toString(),
                        ),
                      ),
                      DataCell(
                        Text(
                          livraison['colis_id'].toString(),
                        ),
                      ),
                      DataCell(
                        Text(
                          livraison['date_depart'].toString(),
                        ),
                      ),
                      DataCell(
                        Text(
                          livraison['date_arrivee_prevue'].toString(),
                        ),
                      ),
                      DataCell(
                        InkWell(
                          onTap: () => _moveToLocation(
                            livraison['itineraire'],
                          ),
                          child: const Text(
                            'Itinéraire',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          livraison['statut_colis'].toString(),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () => sendPosition(
                            livraison['livraison_id'],
                            livraison['chauffeur_id'],
                          ),
                        ),
                      ),
                      DataCell(Checkbox(
                        value: deliveredStatus[index],
                        onChanged: (bool? value) {
                          if (value == true) {
                            setState(() {
                              deliveredStatus[index] = true;
                              delayedStatus[index] = false;
                            });
                            _updateStatus(livraison['livraison_id'], "Livrée");
                          }
                        },
                        activeColor: Colors.green,
                      )),
                      DataCell(Checkbox(
                        value: delayedStatus[index],
                        onChanged: (bool? value) {
                          if (value == true) {
                            setState(() {
                              delayedStatus[index] = true;
                              deliveredStatus[index] = false;
                            });
                            _updateStatus(
                                livraison['livraison_id'], "Retardée");
                          }
                        },
                        activeColor: Colors.red,
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
