import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;

import '../model/transaction_model.dart';

// Web: localStorage for data; blob download for files
class FileStorage {
  final String storageKey;
  FileStorage({this.storageKey = 'transactions_json'});

  Future<List<TransactionModel>> readTransactions() async {
    try {
      final content = html.window.localStorage[storageKey];
      if (content == null || content.trim().isEmpty) return [];
      final decoded = jsonDecode(content) as List<dynamic>;
      return decoded
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> writeTransactions(List<TransactionModel> list) async {
    html.window.localStorage[storageKey] =
        jsonEncode(list.map((e) => e.toJson()).toList());
  }

  Future<String> savePdf(Uint8List bytes, String name) async {
    _download(bytes, name, 'application/pdf');
    return 'download:$name';
  }

  Future<String> exportJson(List<TransactionModel> list) async {
    final data =
        utf8.encode(jsonEncode(list.map((e) => e.toJson()).toList()));
    _download(Uint8List.fromList(data),
        'transactions_export_${DateTime.now().millisecondsSinceEpoch}.json',
        'application/json');
    return 'download';
  }

  void _download(Uint8List bytes, String name, String mime) {
    final blob = html.Blob([bytes], mime);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final a = html.AnchorElement(href: url)..download = name;
    html.document.body?.append(a);
    a.click();
    a.remove();
    html.Url.revokeObjectUrl(url);
  }
}

// Not supported on Web; used for conditional import
Future<String> readStringFromPath(String path) async {
  throw UnsupportedError('File path read is not supported on Web');
}