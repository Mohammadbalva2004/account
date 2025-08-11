// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:path_provider/path_provider.dart';
//
// import '../model/transaction_model.dart';
//
// // IO (Android/iOS/Windows/macOS/Linux)
// class FileStorage {
//   final String filename;
//   FileStorage({this.filename = 'transactions.json'});
//
//   Future<File> _localFile() async {
//     final dir = await getApplicationDocumentsDirectory();
//     return File('${dir.path}/$filename');
//   }
//
//   Future<List<TransactionModel>> readTransactions() async {
//     try {
//       final f = await _localFile();
//       if (!await f.exists()) return [];
//       final content = await f.readAsString();
//       if (content.trim().isEmpty) return [];
//       final decoded = jsonDecode(content) as List<dynamic>;
//       return decoded
//           .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (_) {
//       return [];
//     }
//   }
//
//   Future<void> writeTransactions(List<TransactionModel> list) async {
//     final f = await _localFile();
//     await f.writeAsString(
//       jsonEncode(list.map((e) => e.toJson()).toList()),
//       flush: true,
//     );
//   }
//
//   Future<String> savePdf(Uint8List bytes, String name) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/$name');
//     await file.writeAsBytes(bytes, flush: true);
//     return file.path;
//   }
//
//   Future<String> exportJson(List<TransactionModel> list) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File(
//         '${dir.path}/transactions_export_${DateTime.now().millisecondsSinceEpoch}.json');
//     await file.writeAsString(
//       jsonEncode(list.map((e) => e.toJson()).toList()),
//       flush: true,
//     );
//     return file.path;
//   }
// }
//
// // Helper for file import on IO
// Future<String> readStringFromPath(String path) async {
//   return File(path).readAsString();
// }

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../model/transaction_model.dart';

// IO (Android/iOS/Windows/macOS/Linux)
class FileStorage {
  final String filename;
  FileStorage({this.filename = 'transactions.json'});

  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$filename');
  }

  Future<List<TransactionModel>> readTransactions() async {
    try {
      final f = await _localFile();
      if (!await f.exists()) return [];
      final content = await f.readAsString();
      if (content.trim().isEmpty) return [];
      final decoded = jsonDecode(content) as List<dynamic>;
      return decoded
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> writeTransactions(List<TransactionModel> list) async {
    final f = await _localFile();
    await f.writeAsString(
      jsonEncode(list.map((e) => e.toJson()).toList()),
      flush: true,
    );
  }

  Future<String> savePdf(Uint8List bytes, String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<String> exportJson(List<TransactionModel> list) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/transactions_export_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(
      jsonEncode(list.map((e) => e.toJson()).toList()),
      flush: true,
    );
    return file.path;
  }
}

// Helper for file import on IO
Future<String> readStringFromPath(String path) async {
  return File(path).readAsString();
}
