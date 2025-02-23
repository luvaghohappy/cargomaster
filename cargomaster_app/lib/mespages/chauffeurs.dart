import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../const.dart';

class AjouterChauffeurVehicule extends StatefulWidget {
  @override
  _AjouterChauffeurVehiculeState createState() =>
      _AjouterChauffeurVehiculeState();
}

class _AjouterChauffeurVehiculeState extends State<AjouterChauffeurVehicule> {
  final TextEditingController _nomChauffeur = TextEditingController();
  final TextEditingController _emailChauffeur = TextEditingController();
  final TextEditingController _telephoneChauffeur = TextEditingController();
  final TextEditingController _passwordChauffeur = TextEditingController();
  final TextEditingController _marqueVehicule = TextEditingController();
  final TextEditingController _modeleVehicule = TextEditingController();
  final TextEditingController _immatriculationVehicule =
      TextEditingController();
  String? selectedtype;
  List<Map<String, dynamic>> _vehicules = [];
  String? _selectedVehiculeId;

  List<Map<String, dynamic>> _chauffeurs = [];
  // List<Map<String, dynamic>> _vehiculesList = [];

  @override
  void initState() {
    super.initState();
    fetchVehicules();
    fetchChauffeurs();
  }

  Future<void> fetchVehicules() async {
    try {
      final response =
          await http.get(Uri.parse("${AppConstants.baseUrl}getvehicules.php"));
      if (response.statusCode == 200) {
        setState(() {
          _vehicules =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Échec de la récupération des véhicules');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
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

  Future<void> ajouterChauffeur() async {
    if (_selectedVehiculeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un véhicule')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}insertchauffeur.php"),
      body: {
        'noms': _nomChauffeur.text,
        'types': selectedtype,
        'email': _emailChauffeur.text,
        'telephone': _telephoneChauffeur.text,
        'passwords': _passwordChauffeur.text,
        'vehicule_id': _selectedVehiculeId!,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chauffeur ajouté avec succès')),
      );
      _nomChauffeur.clear();

      _emailChauffeur.clear();
      _telephoneChauffeur.clear();
      _passwordChauffeur.clear();
      fetchChauffeurs();
    }
  }

  Future<void> ajouterVehicule() async {
    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}insertvehicule.php"),
      body: {
        'marque': _marqueVehicule.text,
        'modele': _modeleVehicule.text,
        'immatriculation': _immatriculationVehicule.text,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Véhicule ajouté avec succès')),
      );
      _marqueVehicule.clear();
      _modeleVehicule.clear();
      _immatriculationVehicule.clear();
      fetchVehicules();
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Ajouter Chauffeur et Véhicule"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card pour Chauffeur
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            "Ajouter un Chauffeur",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: _nomChauffeur,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: const InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      labelText: 'Noms Chauffeur',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  width: 100,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedtype,
                                    style: const TextStyle(color: Colors.black),
                                    items: ['Pilote', 'capitaine', 'chauffeur']
                                        .map((label) => DropdownMenuItem(
                                              child: Text(label),
                                              value: label,
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedtype = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      fillColor: Colors.white, // Fond blanc
                                      filled: true,

                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),

                                      labelText: 'Types',
                                      suffixIcon: Icon(Icons.arrow_back_ios),
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: _telephoneChauffeur,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: const InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      labelText: 'Téléphone',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: _passwordChauffeur,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: const InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      labelText: 'Mot de Passe',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: _emailChauffeur,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: const InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      labelText: 'Email',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  width: 100,
                                  child: DropdownButtonFormField<String>(
                                    style: const TextStyle(color: Colors.black),
                                    value: _selectedVehiculeId,
                                    isExpanded: true,
                                    items: _vehicules.isEmpty
                                        ? []
                                        : _vehicules.map((vehicule) {
                                            return DropdownMenuItem<String>(
                                              value: vehicule['vehicule_id'] ??
                                                  ''.toString(),
                                              child: Text(
                                                "${vehicule['marque'] ?? ''} - ${vehicule['immatriculation'] ?? ''}",
                                              ),
                                            );
                                          }).toList(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedVehiculeId = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      fillColor: Colors.white, // Fond blanc
                                      filled: true,

                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),

                                      labelText: 'Sélectionner un véhicule',
                                      suffixIcon: Icon(Icons.arrow_back_ios),
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: ajouterChauffeur,
                            child: Container(
                              height: 50,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  "Ajouter Chauffeur",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Card pour Véhicule
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Container(
                      height: h * 0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              "Ajouter un Véhicule",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 20),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: _marqueVehicule,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      decoration: const InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        labelText: 'Type vehicule',
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: _modeleVehicule,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      decoration: const InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        labelText: 'Modele',
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  width: 320,
                                  child: TextField(
                                    controller: _immatriculationVehicule,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: const InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      labelText: 'Immatriculation',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: ajouterVehicule,
                              child: Container(
                                height: 50,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Center(
                                  child: Text(
                                    "Ajouter Véhicule",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DataTable(
                          columnSpacing: 20.0,
                          headingRowColor: MaterialStateProperty.all(
                            Colors.deepOrange.shade100,
                          ),
                          columns: const [
                            DataColumn(
                              label: Text('ID'),
                            ),
                            DataColumn(
                              label: Text('Noms chauffeur'),
                            ),
                            DataColumn(
                              label: Text('Types'),
                            ),
                            DataColumn(
                              label: Text('Email'),
                            ),
                            DataColumn(
                              label: Text('Téléphone'),
                            ),
                            DataColumn(
                              label: Text('Mot de Passe'),
                            ),
                            DataColumn(
                              label: Text('Véhicule'),
                            ),
                          ],
                          rows: _chauffeurs.map((chauffeur) {
                            return DataRow(cells: [
                              DataCell(
                                Text(
                                  chauffeur['chauffeur_id'].toString(),
                                ),
                              ),
                              DataCell(
                                Text(chauffeur['noms'] ?? ''),
                              ),
                              DataCell(
                                Text(chauffeur['types'] ?? ''),
                              ),
                              DataCell(
                                Text(chauffeur['email'] ?? ''),
                              ),
                              DataCell(
                                Text(chauffeur['telephone'] ?? ''),
                              ),
                              DataCell(
                                Text(
                                  chauffeur['passwords'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(chauffeur['vehicule_id'] ?? ''),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Card(
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DataTable(
                          columnSpacing: 20.0,
                          headingRowColor: MaterialStateProperty.all(
                            Colors.deepOrange.shade100,
                          ),
                          columns: const [
                            DataColumn(
                              label: Text('ID'),
                            ),
                            DataColumn(
                              label: Text('Type'),
                            ),
                            DataColumn(
                              label: Text('Modèle'),
                            ),
                            DataColumn(
                              label: Text('Immatriculation'),
                            ),
                          ],
                          rows: _vehicules.map((vehicule) {
                            return DataRow(cells: [
                              DataCell(
                                Text(
                                  vehicule['vehicule_id'].toString(),
                                ),
                              ),
                              DataCell(
                                Text(vehicule['marque'] ?? ''),
                              ),
                              DataCell(
                                Text(vehicule['modele'] ?? ''),
                              ),
                              DataCell(
                                Text(vehicule['immatriculation'] ?? ''),
                              ),
                            ]);
                          }).toList(),
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
    );
  }
}
