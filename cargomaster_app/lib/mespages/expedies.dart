import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../const.dart';

class Expedies extends StatefulWidget {
  const Expedies({super.key});

  @override
  State<Expedies> createState() => _ExpediesState();
}

class _ExpediesState extends State<Expedies> {
  List<Map<String, dynamic>> _items = [];
  // late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void _openGoogleMaps(String positionActuelle) async {
    print("Position reçue : $positionActuelle"); // Afficher les coordonnées

    try {
      List<String> coords = positionActuelle.split(',');
      double lat = double.parse(coords[0].trim());
      double lon = double.parse(coords[1].trim());

      print(
          "Latitude: $lat, Longitude: $lon"); // Vérifier les valeurs avant ouverture

      String url = "https://www.google.com/maps/place/$lat,$lon";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print("Impossible d'ouvrir Google Maps");
      }
    } catch (e) {
      print("Erreur lors du lancement de Google Maps: $e");
    }
  }

  /// 📌 Récupération des données depuis le backend
  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse("${AppConstants.baseUrl}getexpediction.php"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _items = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          print("Données reçues du serveur : ${response.body}");

          print("Aucune livraison trouvée.");
        }
      } else {
        throw Exception('Échec de la récupération des données.');
      }
    } catch (e) {
      print("Erreur: $e");
    }
  }

  void _openGoogleMapsMultiple(List<String> positions) async {
    try {
      if (positions.isEmpty) return;

      String baseUrl = "https://www.google.com/maps/dir/";
      String coordinates =
          positions.join("/"); // Concatène toutes les positions
      String url = "$baseUrl$coordinates";

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print("Impossible d'ouvrir Google Maps");
      }
    } catch (e) {
      print("Erreur lors de l'ouverture de Google Maps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expéditions En cours, Livrée et retardée'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
          ),
          GestureDetector(
            onTap: () {
              List<String> positions = _items
                  .where((item) =>
                      item['etat'] == 'En route' &&
                      item['position_actuelle'] != null)
                  .map((item) => item['position_actuelle'] as String)
                  .toList();

              if (positions.isNotEmpty) {
                _openGoogleMapsMultiple(positions);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Aucune expédition en route trouvée"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Container(
              height: 30,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Traffics',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          _items.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 0.1,
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 15.0,
                          headingRowColor: MaterialStateProperty.all(
                              Colors.deepOrange.shade100),
                          columns: const [
                            DataColumn(
                              label: Text('#'),
                            ),
                            DataColumn(
                              label: Text('Livraison'),
                            ),
                            DataColumn(
                              label: Text('Chauffeur'),
                            ),
                            DataColumn(
                              label: Text('Position'),
                            ),
                            DataColumn(
                              label: Text('État'),
                            ),
                          ],
                          rows: _items.asMap().entries.map((entry) {
                            int index = entry.key + 1;
                            Map<String, dynamic> item = entry.value;
                            return DataRow(cells: [
                              DataCell(
                                Text(
                                  index.toString(),
                                ),
                              ),
                              DataCell(
                                Text(
                                  item['livraison_id'].toString(),
                                ),
                              ),
                              DataCell(
                                Text(item['chauffeur_id'] ?? ''),
                              ),
                              DataCell(
                                InkWell(
                                  onTap: () {
                                    _openGoogleMaps(
                                        item['position_actuelle'] ?? '');
                                  },
                                  child: const Text(
                                    '📍 Suivre la position',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(item['etat'] ?? ''),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
