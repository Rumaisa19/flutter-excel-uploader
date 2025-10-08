import 'package:excel_api_uploader/service/save_developer_to_excel.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import '../../model/developerModel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


// ----------------------------
// API Function
// ----------------------------
Future<bool> postData(DeveloperModel dev) async {
  try {
    final url = Uri.parse("https://jsonplaceholder.typicode.com/posts");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(dev.toJson()),
    );

    print("Response: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    return false;
  }
}

// ----------------------------
// UI Screen
// ----------------------------
class ExcelViewerPage extends StatefulWidget {
  const ExcelViewerPage({super.key});

  @override
  State<ExcelViewerPage> createState() => _ExcelViewerPageState();
}

class _ExcelViewerPageState extends State<ExcelViewerPage> {
  List<DeveloperModel> developers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadExcel();
  }

  // ✅ Load Excel (updated file if available, else asset)
Future<void> loadExcel() async {
  try {
    List<int>? fileBytes;

    // 1. Check updated file in documents directory
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/developers_with_response.xlsx";
    final file = File(filePath);

    if (await file.exists()) {
      fileBytes = await file.readAsBytes();
    } else {
      final data = await rootBundle.load(
        "assets/excel_api_uploader_developers.xlsx",
      );
      fileBytes = data.buffer.asUint8List();
    }

    // 2. Decode Excel
    var excel = Excel.decodeBytes(fileBytes);
    List<DeveloperModel> loaded = [];

    for (var table in excel.tables.keys) {
      final rows = excel.tables[table]!.rows;
      loaded = rows.skip(1).map((row) {
        return DeveloperModel(
          id: row[0]?.value.toString() ?? '',
          name: row[1]?.value.toString() ?? '',
          email: row[2]?.value.toString() ?? '',
          message: row[3]?.value.toString() ?? '',
          response: row.length > 4 ? (row[4]?.value.toString() ?? '') : '',
        );
      }).toList();
      break;
    }

    setState(() {
      developers = loaded;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      developers = [];
      isLoading = false;
    });
  }
}
  // ✅ Open/Share updated Excel
  Future<void> _openUpdatedExcel() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/developers_with_response.xlsx";
      final file = File(filePath);

      if (await file.exists()) {
        await Share.shareXFiles([
          XFile(filePath),
        ], text: "Here is the updated Excel file 📊");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ No updated Excel file found.")),
        );
      }
    } catch (e) {
      print("❌ Error sharing Excel: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Excel API Uploader",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        toolbarHeight: 80,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : developers.isEmpty
              ? const Center(child: Text("No data found in Excel"))
              : ListView.builder(
                  itemCount: developers.length,
                  itemBuilder: (context, index) {
                    final dev = developers[index];
                    return Card(
                      color: Colors.orange[50],
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Text(dev.id.replaceAll("D", "")),
                        ),
                        title: Text(
                          dev.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${dev.email}'),
                            Text(
                              'Message: ${dev.message}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            if (dev.response.isNotEmpty)
                              Text('Response: ${dev.response}'),
                          ],
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: () async {
                            final success = await postData(dev);

                            setState(() {
                              dev.response = success
                                  ? "Posted Successfully"
                                  : "Failed to Post";
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(dev.response)),
                            );

                            await saveDevelopersToExcel(developers);
                          },
                          icon: const Icon(Icons.upload),
                          label: const Text("Post"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUpdatedExcel,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.insert_drive_file, color: Colors.white),
        label: const Text("View Excel", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}