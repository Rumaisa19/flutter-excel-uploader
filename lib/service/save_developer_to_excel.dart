import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import '../model/developerModel.dart'; // import your model

// ----------------------------
// Save Developers List to Excel
// ----------------------------
Future<void> saveDevelopersToExcel(List<DeveloperModel> developers) async {
  // 1. Create new Excel workbook
  var excel = Excel.createExcel();

  // 2. Select first sheet
  Sheet sheetObject = excel['Sheet1'];

  // 3. Add header row
  sheetObject.appendRow([
    'ID',
    'Name',
    'Email',
    'Message',
    'Response',
  ]);

  // 4. Add each developer row
  for (var dev in developers) {
    sheetObject.appendRow([
      dev.id,
      dev.name,
      dev.email,
      dev.message,
      dev.response, // ✅ includes updated response
    ]);
  }

  // 5. Get app storage directory (works on Android, iOS, Desktop)
  Directory dir = await getApplicationDocumentsDirectory();
  String filePath = "${dir.path}/developers_with_response.xlsx";

  // 6. Save the Excel file
  final excelBytes = excel.encode();
  if (excelBytes != null) {
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excelBytes);
    stdout.write("✅ Excel saved at: $filePath");
  } else {
    stdout.write("❌ Failed to encode Excel file.");
  }
}
