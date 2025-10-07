import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:excel_api_uploader/screens/homePage.dart';
import 'package:excel_api_uploader/service/save_developer_to_excel.dart';
import 'package:flutter/material.dart';

import '../../model/developerModel.dart';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class _ExcelViewerPageState extends State<ExcelViewerPage> {
  List<DeveloperModel> developers = [];
  bool isLoading = true;

  // ✅ Function to open/share updated Excel
  Future<void> _openUpdatedExcel() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/developers_with_response.xlsx";
      final file = File(filePath);

      if (await file.exists()) {
        // Share the file
        await OpenFilex.open((filePath));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ No updated Excel file found yet.")),
        );
      }
    } catch (e) {
      print("❌ Error opening Excel: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error opening Excel file")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(dev.response)));

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

      // ✅ Add Floating Button to open Excel
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUpdatedExcel,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.insert_drive_file, color: Colors.white),
        label: const Text("View Excel", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
