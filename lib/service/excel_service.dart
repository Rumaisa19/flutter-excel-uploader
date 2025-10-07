import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import '../model/developerModel.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<void> saveResponseToExcel(DeveloperModel dev) async {
  // 1. Load the existing excel file again
  final data = await rootBundle.load(
    "assets/excel_api_uploader_developers.xlsx",
  );
  var bytes = data.buffer.asUint8List();
  var excel = Excel.decodeBytes(bytes);

  // 2. Get first sheet
  var sheet = excel.tables[excel.tables.keys.first]!;

  // 3. Find the row index by ID
  for (int i = 1; i < sheet.rows.length; i++) {
    if (sheet.rows[i][0]?.value.toString() == dev.id) {
      // Write response in 5th column (index 4)
      sheet.updateCell(
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i),
        dev.response,
      );
      break;
    }
  }

  // 4. Encode back to bytes
  final fileBytes = excel.encode();

  // 5. Save updated excel file in documents folder
  if (fileBytes != null) {
    Directory dir = await getApplicationDocumentsDirectory();
    String filePath = "${dir.path}/developers_updated.xlsx";
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);
    stdout.write("✅ Excel updated & saved at: $filePath");
  }
}
