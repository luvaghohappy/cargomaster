import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import '../const.dart';

class Livraisons extends StatefulWidget {
  final int? colisId;
  final String? adresse_livraison;

  const Livraisons({super.key, this.colisId, this.adresse_livraison});

  @override
  State<Livraisons> createState() => _LivraisonsState();
}

class _LivraisonsState extends State<Livraisons> {
  TextEditingController dateDepartController = TextEditingController();
  TextEditingController dateArriveeController = TextEditingController();
  TextEditingController dureeController = TextEditingController();
  TextEditingController itineraireController = TextEditingController();
  List<Map<String, dynamic>> _chauffeurs = [];
  List<Map<String, dynamic>> filteredItems = [];
  String? _selectedChauffeurId;
  Timer? _timer;
  String searchQuery = '';
  List<Map<String, dynamic>> livraisons = [];
  Location location = Location(); // Initialisation de la localisation

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInsertLivraisonDialog(context);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchChauffeurs();
      // fetchLivraisons();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _openGoogleMaps() async {
    try {
      LocationData currentLocation = await location.getLocation();

      String url =
          'https://www.google.com/maps/dir/?api=1&origin=${currentLocation.latitude},${currentLocation.longitude}&destination=${widget.adresse_livraison}';

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not open the map.';
      }
    } catch (e) {
      print('Erreur lors de l\'obtention de la localisation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'obtention de la localisation'),
        ),
      );
    }
  }

  Future<void> showInsertLivraisonDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: const Text('Ajouter Colis à la Livraison'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: dateDepartController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Date de départ',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      readOnly: true, // Prevent manual input
                      onTap: () async {
                        // Pick the date
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          // Pick the time after picking the date
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            // Combine Date and Time
                            DateTime fullDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );

                            setState(() {
                              // Format the DateTime as "YYYY-MM-DD HH:MM:SS"
                              dateDepartController.text =
                                  fullDateTime.toString().split('.')[0];
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateArriveeController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Date Arrivee prevue',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      readOnly: true, // Prevent manual input
                      onTap: () async {
                        // Pick the date
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          // Pick the time after picking the date
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            // Combine Date and Time
                            DateTime fullDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );

                            setState(() {
                              // Format the DateTime as "YYYY-MM-DD HH:MM:SS"
                              dateArriveeController.text =
                                  fullDateTime.toString().split('.')[0];
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedChauffeurId,
                      isExpanded: true,
                      items: _chauffeurs.map((chauffeur) {
                        return DropdownMenuItem<String>(
                          value: chauffeur['chauffeur_id'].toString(),
                          child: Text(
                              "${chauffeur['noms']} - ${chauffeur['types']}"),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedChauffeurId = value;
                        });
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Sélectionner un chauffeur',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: itineraireController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        fillColor: Colors.white, // Fond blanc
                        filled: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Itineraire',
                        labelStyle: const TextStyle(color: Colors.black),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.location_pin,
                            size: 15,
                          ),
                          onPressed: () {
                            _openGoogleMaps();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler')),
                TextButton(
                  onPressed: insertData,
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> insertData() async {
    if (_selectedChauffeurId == null ||
        dateDepartController.text.isEmpty ||
        dateArriveeController.text.isEmpty ||
        itineraireController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}insertlivraison.php"),
        body: {
          'chauffeur_id': _selectedChauffeurId,
          'colis_id': widget.colisId?.toString() ?? '0',
          'date_depart': dateDepartController.text,
          'date_arrivee_prevue': dateArriveeController.text,
          'statut': 'Planifiée',
          'statut_colis': 'Prêt à être livré',
          'itineraire': itineraireController.text,
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Livraison ajoutée avec succès')),
          );
          Navigator.of(context).pop();
          fetchLivraisons();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["message"])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de l\'insertion des données')),
      );
    }
  }

  Future<void> fetchChauffeurs() async {
    final response =
        await http.get(Uri.parse("${AppConstants.baseUrl}getchauffeurs.php"));
    if (response.statusCode == 200) {
      setState(() {
        _chauffeurs =
            List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    }
  }

  Future<void> fetchLivraisons() async {
    try {
      final response =
          await http.get(Uri.parse("${AppConstants.baseUrl}getlivraison.php"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            livraisons = List<Map<String, dynamic>>.from(data['data']);
            filteredItems = livraisons;
          });
        } else if (data['status'] == 'empty') {
          setState(() {
            livraisons = [];
            filteredItems = [];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucune livraison trouvée.')),
          );
        } else {
          throw Exception("Erreur du serveur : ${data['message']}");
        }
      } else {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de récupération des livraisons : $e')),
      );
    }
  }

  void _filterItems(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredItems = livraisons;
      } else {
        filteredItems = livraisons.where((user) {
          final name = '${user['date_depart']}';
          return name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> deleteLivraison(String id) async {
    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}deletelivraison.php"),
      body: {'livraison_id': id},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livraison supprimée avec succès')),
      );
      fetchLivraisons();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Colis a Livrés"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Aligner au début
                children: [
                  /// --- SEARCH BAR ---
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 300,
                        child: TextField(
                          onChanged: _filterItems,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Rechercher ...',
                            hintStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (filteredItems.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'Aucune Livraison trouvée',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DataTable(
                        columnSpacing: 20.0,
                        headingRowColor: MaterialStateProperty.all(
                          Colors.deepOrange.shade100,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text('ID Livraison'),
                          ),
                          DataColumn(
                            label: Text('Vehicule ID'),
                          ),
                          DataColumn(
                            label: Text('Chauffeur'),
                          ),
                          DataColumn(
                            label: Text('Colis ID'),
                          ),
                          DataColumn(
                            label: Text('Date Départ'),
                          ),
                          DataColumn(
                            label: Text('Date Arrivée'),
                          ),
                          DataColumn(
                            label: Text('Itineraire'),
                          ),
                          DataColumn(
                            label: Text('Statut'),
                          ),
                          DataColumn(
                            label: Text('Statut Colis'),
                          ),
                          DataColumn(
                            label: Text('Actions'),
                          ),
                        ],
                        rows: livraisons.map((livraison) {
                          return DataRow(
                            cells: [
                              DataCell(Text(
                                livraison['livraison_id'].toString(),
                              )),
                              DataCell(Text(
                                livraison['vehicule_id'].toString(),
                              )),
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
                                Text(
                                  livraison['itineraire'] ?? "N/A",
                                ),
                              ),
                              DataCell(
                                Text(
                                  livraison['statut'].toString(),
                                ),
                              ),
                              DataCell(
                                Text(
                                  livraison['statut_colis'].toString(),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => deleteLivraison(
                                        livraison['livraison_id'].toString(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
