import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'const.dart';
import 'mespages/chauffeurs.dart';
import 'mespages/colis.dart';
import 'mespages/expedies.dart';
import 'mespages/livraison.dart';
import 'mespages/utilisateur.dart';
import 'mylogin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MARGO MASTER',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(color: Colors.black),
      ),
      home: DashboardScreen(
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
      // routes: {
      //   '/home': (context) => DashboardScreen(
      //         isDarkMode: _themeMode == ThemeMode.dark,
      //         onToggleTheme: _toggleTheme,
      //       ),
      // },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onToggleTheme;

  const DashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            isDarkMode: isDarkMode,
            onToggleTheme: onToggleTheme,
          ),
          Expanded(
            child: DashboardContent(),
          ),
        ],
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  final Function(bool) onToggleTheme;
  final bool isDarkMode;

  const SideMenu({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CARGO MASTER',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              IconButton(
                icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                onPressed: () => onToggleTheme(!isDarkMode),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SideMenuItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            isActive: true,
            onTap: () {},
            isDarkMode: isDarkMode,
          ),
          SideMenuItem(
            icon: Icons.person_2_outlined,
            label: 'Clients',
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Clients(),
                ),
              );
            },
          ),
          SideMenuItem(
            icon: Icons.person_2_outlined,
            label: 'Colis',
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Colis(),
                ),
              );
            },
          ),
          SideMenuItem(
            icon: Icons.car_rental_outlined,
            label: 'Chauffeurs et Vehicules',
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AjouterChauffeurVehicule(),
                ),
              );
            },
          ),
          SideMenuItem(
            icon: Icons.delivery_dining,
            label: 'Livraisons',
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Livraisons(),
                ),
              );
            },
          ),
          SideMenuItem(
            icon: Icons.track_changes,
            label: 'Colis Expediés',
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Expedies(),
                ),
              );
            },
          ),
          SideMenuItem(
            icon: Icons.logout_outlined,
            label: 'Deconnexion',
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MyLogin(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SideMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDarkMode;

  const SideMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDarkMode ? Colors.blue : Colors.orange;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: isActive ? activeColor : textColor),
        title: Text(
          label,
          style: TextStyle(color: isActive ? activeColor : textColor),
        ),
        tileColor: isActive ? activeColor.withOpacity(0.2) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchStates();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<Map<String, int>> fetchStates() async {
    final response =
        await http.get(Uri.parse("${AppConstants.baseUrl}getstates.php"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Map<String, int> states = {};
      for (var item in data) {
        states[item['table_name']] = int.parse(item['record_count']);
      }
      return states;
    } else {
      throw Exception('Erreur lors de la récupération des statistiques');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, int>>(
          future: fetchStates(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            final states = snapshot.data ?? {};

            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatCard(
                          title: 'Clients',
                          value: states['clients']?.toString() ?? '0',
                          icon: Icons.person),
                      const SizedBox(
                        width: 40,
                      ),
                      StatCard(
                          title: 'Colis',
                          value: states['colis']?.toString() ?? '0',
                          icon: Icons.drive_file_move_rounded),
                      const SizedBox(
                        width: 40,
                      ),
                      StatCard(
                          title: 'Chauffeurs',
                          value: states['chauffeurs']?.toString() ?? '0',
                          icon: Icons.person_add_alt_rounded),
                      const SizedBox(
                        width: 40,
                      ),
                      StatCard(
                          title: 'Véhicules',
                          value: states['vehicules']?.toString() ?? '0',
                          icon: Icons.directions_car),
                      const SizedBox(
                        width: 40,
                      ),
                      StatCard(
                          title: 'Livraisons',
                          value: states['livraisons']?.toString() ?? '0',
                          icon: Icons.local_shipping),
                      const SizedBox(
                        width: 40,
                      ),
                      StatCard(
                          title: 'Expéditions',
                          value: states['expeditions']?.toString() ?? '0',
                          icon: Icons.send),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Card(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Graphique des données',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 250,
                                  child: TransactionsChart(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 400,
                          child: DataTableWidget(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TransactionsChart extends StatefulWidget {
  @override
  _TransactionsChartState createState() => _TransactionsChartState();
}

class _TransactionsChartState extends State<TransactionsChart> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchStates();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchStates() async {
    final response =
        await http.get(Uri.parse("${AppConstants.baseUrl}getstates.php"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Erreur lors de la récupération des statistiques');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchStates(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erreur: ${snapshot.error}'),
                    );
                  }

                  final states = snapshot.data ?? [];
                  if (states.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune donnée disponible',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: states
                                    .map(
                                      (e) => int.parse(
                                        e['record_count'],
                                      ),
                                    )
                                    .reduce((a, b) => a > b ? a : b)
                                    .toDouble() +
                                5, // Ajuster la hauteur max
                            barGroups: _chartData(states),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int labelValue = (value ~/ 5) * 5;
                                    if (labelValue <= meta.max) {
                                      return Text(
                                        labelValue.toString(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < states.length) {
                                      return Text(
                                        states[index]['table_name'],
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: states.map((state) {
                          final color = _getColor(state['table_name']);
                          return _Legend(
                              color: color, text: state['table_name']);
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _chartData(List<Map<String, dynamic>> states) {
    return List.generate(states.length, (index) {
      final state = states[index];
      final count = int.parse(state['record_count']).toDouble();
      final color = _getColor(state['table_name']);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count,
            color: color,
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Color _getColor(String tableName) {
    final colors = {
      'clients': Colors.blue,
      'colis': Colors.red,
      'livraisons': Colors.green,
      'expeditions': Colors.orange,
      'chauffeurs': Colors.purple,
      'vehicules': Colors.teal,
    };
    return colors[tableName] ?? Colors.grey;
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class DataTableWidget extends StatefulWidget {
  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}selectclient.php"),
      );
      setState(() {
        items = List<Map<String, dynamic>>.from(
          json.decode(response.body),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load items'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.1),
        ),
        child: DataTable(
          columnSpacing: 20.0,
          headingRowColor:
              MaterialStateProperty.all(Colors.deepOrange.shade100),
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Noms')),
            DataColumn(label: Text('Adresse')),
            DataColumn(label: Text('Téléphone')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Date Ajout')),
            DataColumn(label: Text('Actions')),
          ],
          rows: List.generate(items.length, (index) {
            final item = items[index];
            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(item['noms'] ?? '')),
                DataCell(Text(item['adresse'] ?? '')),
                DataCell(Text(item['telephone'] ?? '')),
                DataCell(Text(item['email'] ?? '')),
                DataCell(Text(item['date_ajout'] ?? '')),
                DataCell(
                  Checkbox(
                    value: true,
                    activeColor: Colors.green,
                    onChanged: (bool? value) {},
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard(
      {super.key,
      required this.title,
      required this.value,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 100,
        width: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 25, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
