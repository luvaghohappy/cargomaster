import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../const.dart';
import 'colis.dart';

class Clients extends StatefulWidget {
  const Clients({super.key});

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {
  Future<void> _showEditDialog(Map<String, dynamic> item) async {
    txtnom.text = item['noms'] ?? '';
    txtadresse.text = item['adresse'] ?? '';
    txttelephone.text = item['telephone'] ?? '';
    txtemail.text = item['email'] ?? '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier Information Produit'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 200,
                        child: TextField(
                          controller: txtnom,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            labelText: 'Nom Postnom',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        width: 200,
                        child: TextField(
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 200,
                        child: TextField(
                          controller: txttelephone,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            labelText: 'Téléphone',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        width: 200,
                        child: TextField(
                          controller: txtemail,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
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
              onPressed: () {
                updateData(item['client_id'].toString());
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateData(String id) async {
    final nom = txtnom.text;
    final adresse = txtadresse.text;
    final telephone = txttelephone.text;
    final email = txtemail.text;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${AppConstants.baseUrl}updateclient.php"),
    );

    request.fields['client_id'] = id;
    request.fields['noms'] = nom;
    request.fields['adresse'] = adresse;
    request.fields['telephone'] = telephone;
    request.fields['email'] = email;

    var response = await request.send();

    if (response.statusCode == 200) {
      txtnom.clear();
      txtadresse.clear();
      txttelephone.clear();
      txtemail.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mise à jour réussie'),
        ),
      );
      fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour'),
        ),
      );
    }
  }

  Future<void> showInsertDialog(BuildContext context) async {
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
              title: const Text('Ajouter Client'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: 200,
                            child: TextField(
                              controller: txtnom,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                labelText: 'Nom Postnom',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            width: 200,
                            child: TextField(
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: 200,
                            child: TextField(
                              controller: txttelephone,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                labelText: 'Téléphone',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            width: 200,
                            child: TextField(
                              controller: txtemail,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
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
      Uri.parse("${AppConstants.baseUrl}insertclient.php"),
      body: {
        'noms': txtnom.text,
        'adresse': txtadresse.text,
        'telephone': txttelephone.text,
        'email': txtemail.text,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      txtnom.clear();
      txtadresse.clear();
      txttelephone.clear();
      txtemail.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enregistrement réussi'),
        ),
      );
      fetchData();
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'enregistrement'),
        ),
      );
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}selectclient.php"),
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

  TextEditingController txtnom = TextEditingController();
  TextEditingController txtadresse = TextEditingController();
  TextEditingController txttelephone = TextEditingController();
  TextEditingController txtemail = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> items = [];
  Timer? _timer;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> deleteData(String id) async {
    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}deleteclient.php"),
      body: {'client_id': id},
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Suppression réussie'),
          ),
        );
        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression : ${result['error']}'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression'),
        ),
      );
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: const Text('Voulez-vous vraiment supprimer cet élément ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteData(id);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Gestion des Clients"),
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
                  /// --- HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => showInsertDialog(context),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Ajouter"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                        ),
                      ),
                    ],
                  ),

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
                        border: Border.all(color: Colors.black, width: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DataTable(
                        columnSpacing: 20.0,
                        headingRowColor: MaterialStateProperty.all(
                          Colors.deepOrange.shade100,
                        ),
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('Noms')),
                          DataColumn(label: Text('Adresse')),
                          DataColumn(label: Text('Téléphone')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Date Ajout')),
                          DataColumn(label: Text('Actions')),
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
                                item['noms'] ?? '',
                                style: const TextStyle(color: Colors.black),
                              )),
                              DataCell(Text(
                                item['adresse'] ?? '',
                                style: const TextStyle(color: Colors.black),
                              )),
                              DataCell(Text(
                                item['telephone'] ?? '',
                                style: const TextStyle(color: Colors.black),
                              )),
                              DataCell(Text(
                                item['email'] ?? '',
                                style: const TextStyle(color: Colors.black),
                              )),
                              DataCell(
                                Text(
                                  item['date_ajout'] ?? '',
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
                                            builder: (context) => Colis(
                                              noms: item['noms'],
                                              clientId:
                                                  int.parse(item['client_id']),
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
                                        "Ajouter Colis",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      iconSize: 20,
                                      color: Colors.green,
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        _showEditDialog(item);
                                      },
                                    ),
                                    IconButton(
                                      iconSize: 20,
                                      color: Colors.red,
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        deleteData(item['client_id']);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  const Spacer(),

                  /// --- PAGINATION ---
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () {},
                        ),
                        const Text("Page 1 de 3"),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () {},
                        ),
                      ],
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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isReadOnly = false, VoidCallback? onTap}) {
    return TextFormField(
      controller: controller,
      readOnly: isReadOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Champ requis' : null,
    );
  }
}
