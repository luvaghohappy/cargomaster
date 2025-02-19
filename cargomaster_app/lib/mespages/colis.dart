import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../const.dart';
import 'livraison.dart';

class Colis extends StatefulWidget {
  final String? noms;
  final int? clientId;

  const Colis({
    super.key,
    this.noms,
    this.clientId,
  });

  @override
  State<Colis> createState() => _ColisState();
}

class _ColisState extends State<Colis> {
  TextEditingController txtdescriptions = TextEditingController();
  TextEditingController txtpoints = TextEditingController();
  TextEditingController txtadresse = TextEditingController();
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  Timer? _timer;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInsertColisDialog(context);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> showInsertColisDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey, width: 3),
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: const Text('Ajouter Colis'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: txtdescriptions,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Descriptions Colis',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: txtadresse,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Adresse',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: txtpoints,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Poids colis',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
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
    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}insertcolis.php"),
      body: {
        'client_id': widget.clientId.toString(),
        'noms_client': widget.noms,
        'descriptions': txtdescriptions.text,
        'poids': txtpoints.text,
        'adresse_livraison': txtadresse.text,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      txtdescriptions.clear();
      txtpoints.clear();
      txtadresse.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enregistrement réussi')),
      );

      fetchData();
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'enregistrement')),
      );
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}selectcolis.php"),
      );
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> newItems =
            List<Map<String, dynamic>>.from(json.decode(response.body))
                .reversed
                .toList();

        setState(() {
          items = newItems;
          filteredItems = items;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load items'),
        ),
      );
    }
  }

  void _filterItems(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredItems = items;
      } else {
        filteredItems = items.where((user) {
          final name = '${user['noms']}';
          return name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Gestion des Clients"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Ajout du padding global
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
                          'Aucun élément trouvé',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DataTable(
                        columnSpacing: 20.0,
                        headingRowColor: MaterialStateProperty.all(
                          Colors.deepOrange.shade100,
                        ),
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(
                            label: Text('Client ID'),
                          ),
                          DataColumn(
                            label: Text('Noms client'),
                          ),
                          DataColumn(
                            label: Text('Descriptions'),
                          ),
                          DataColumn(
                            label: Text('Poids colis'),
                          ),
                          DataColumn(
                            label: Text('Adresse Livraison'),
                          ),
                          DataColumn(
                            label: Text('Date '),
                          ),
                          DataColumn(
                            label: Text('Actions'),
                          ),
                        ],
                        rows: List<DataRow>.generate(filteredItems.length,
                            (int index) {
                          final item = filteredItems[index];
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  (index + 1).toString(),
                                ),
                              ),
                              DataCell(Text(
                                item['client_id'] ?? '',
                                style: const TextStyle(color: Colors.black),
                              )),
                              DataCell(Text(
                                item['noms_client'] ?? '',
                                style: const TextStyle(color: Colors.black),
                              )),
                              DataCell(Text(
                                item['descriptions'] ?? '',
                                style: const TextStyle(color: Colors.black),
                              )),
                              DataCell(Text(
                                item['poids'] ?? '',
                                style: const TextStyle(color: Colors.black),
                              )),
                              DataCell(Text(
                                item['adresse_livraison'] ?? '',
                                style: const TextStyle(color: Colors.black),
                              )),
                              DataCell(
                                Text(
                                  item['date_enregistrement	'] ?? '',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => Livraisons(
                                              colisId: int.tryParse(
                                                      item['colis_id']) ??
                                                  0,
                                              adresse_livraison:
                                                  item['adresse_livraison'] ??
                                                      '',
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 16),
                                      ),
                                      child: const Text(
                                        "Livraisons",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
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
