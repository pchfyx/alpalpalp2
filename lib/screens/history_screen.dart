import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, int> intakeHistory = {};

  @override
  void initState() {
    super.initState();
    _loadIntakeHistory();
  }

  Future<void> _loadIntakeHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Load the water intake history from SharedPreferences
    String? historyData = prefs.getString('intakeHistory');
    if (historyData != null) {
      intakeHistory = Map<String, int>.from(json.decode(historyData));
    }
    
    // Add today's intake if it exists
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (intakeHistory.containsKey(today)) {
      print("Today's intake for $today is: ${intakeHistory[today]} ml");
    } else {
      print("Today's intake for $today is not recorded yet.");
    }
    
    setState(() {
      intakeHistory[today] = intakeHistory[today] ?? 0; // Ensure today's entry exists
    });
    print("Intake History Loaded: $intakeHistory"); // Debugging statement
  }

  // Method to refresh the intake history
  Future<void> _refreshIntakeHistory() async {
    await _loadIntakeHistory(); // Reload the history
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("History refreshed")),
    );
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Water Intake History', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Date', 'Intake (ml)'],
                  ...intakeHistory.entries
                      .map((entry) => [entry.key, entry.value.toString()])
                      .toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF file
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/water_intake_history.pdf");
    await file.writeAsBytes(await pdf.save());
    print('PDF saved at ${file.path}');

    // Optionally, show a message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF saved at ${file.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshIntakeHistory, // Call the refresh method
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: intakeHistory.length,
        itemBuilder: (context, index) {
          String date = intakeHistory.keys.elementAt(index);
          int intake = intakeHistory[date]!;
          return ListTile(
            title: Text("$date"),
            subtitle: Text("Water Intake: $intake ml"),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generatePDF, // Call PDF generation on button press
        child: const Icon(Icons.download),
      ),
    );
  }
}
