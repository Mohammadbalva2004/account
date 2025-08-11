// import 'dart:convert';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../model/transaction_model.dart';
// import '../storage/storage_io.dart' as io if (dart.library.html) '../storage/storage_web.dart';
//
// class AddEditTransactionSheet extends StatefulWidget {
//   final TransactionModel? initial;
//   const AddEditTransactionSheet({super.key, this.initial});
//
//   static Future<void> importJson(BuildContext context,
//       {required void Function(List<TransactionModel>) onImported}) async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['json'],
//         withData: true,
//       );
//       if (result == null) return;
//
//       String content;
//       final path = result.files.single.path;
//       if (path != null && path.isNotEmpty) {
//         content = await io.readStringFromPath(path);
//       } else if (result.files.single.bytes != null) {
//         content = utf8.decode(result.files.single.bytes!);
//       } else {
//         throw 'Could not read file';
//       }
//       final List<dynamic> decoded = jsonDecode(content);
//       final imported = decoded
//           .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//       onImported(imported);
//       if (context.mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text('Imported JSON file')));
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Import failed: $e')));
//       }
//     }
//   }
//
//   @override
//   State<AddEditTransactionSheet> createState() => _AddEditTransactionSheetState();
// }
//
// class _AddEditTransactionSheetState extends State<AddEditTransactionSheet> {
//   final _formKey = GlobalKey<FormState>();
//   late String _type;
//   final _amountCtrl = TextEditingController();
//   final _noteCtrl = TextEditingController();
//   String? _category = kCategories.first;
//   DateTime _date = DateTime.now();
//
//   @override
//   void initState() {
//     super.initState();
//     final init = widget.initial;
//     _type = init?.type ?? 'income';
//     _amountCtrl.text = init?.amount.toStringAsFixed(2) ?? '';
//     _noteCtrl.text = init?.note ?? '';
//     _category = init?.category ?? kCategories.first;
//     _date = init?.date ?? DateTime.now();
//   }
//
//   @override
//   void dispose() {
//     _amountCtrl.dispose();
//     _noteCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickDate() async {
//     final d = await showDatePicker(
//       context: context,
//       initialDate: _date,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (d != null) setState(() => _date = d);
//   }
//
//   void _submit() {
//     if (!_formKey.currentState!.validate()) return;
//     final amt = double.parse(_amountCtrl.text);
//     final t = TransactionModel(
//       id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       type: _type,
//       amount: amt,
//       note: _noteCtrl.text.trim(),
//       date: _date,
//       category: _category,
//     );
//     Navigator.pop(context, t);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final insets = MediaQuery.of(context).viewInsets.bottom;
//     final df = DateFormat('dd MMM yyyy');
//
//     return Padding(
//       padding: EdgeInsets.only(bottom: insets),
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(widget.initial == null ? 'Add Transaction' : 'Edit Transaction',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
//             const SizedBox(height: 12),
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   // Type
//                   SegmentedButton<String>(
//                     segments: const [
//                       ButtonSegment(value: 'income', icon: Icon(Icons.trending_up), label: Text('Income')),
//                       ButtonSegment(value: 'expense', icon: Icon(Icons.trending_down), label: Text('Expense')),
//                     ],
//                     selected: {_type},
//                     showSelectedIcon: false,
//                     onSelectionChanged: (s) => setState(() => _type = s.first),
//                   ),
//                   const SizedBox(height: 12),
//                   // Amount
//                   TextFormField(
//                     controller: _amountCtrl,
//                     keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                     decoration: const InputDecoration(
//                       labelText: 'Amount',
//                       prefixIcon: Icon(Icons.currency_rupee),
//                     ),
//                     validator: (v) {
//                       if (v == null || v.trim().isEmpty) return 'Enter amount';
//                       if (double.tryParse(v) == null) return 'Invalid number';
//                       if (double.parse(v) <= 0) return 'Amount must be > 0';
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   // Category
//                   DropdownButtonFormField<String>(
//                     value: _category,
//                     items: kCategories
//                         .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                         .toList(),
//                     onChanged: (v) => setState(() => _category = v),
//                     decoration: const InputDecoration(
//                       labelText: 'Category',
//                       prefixIcon: Icon(Icons.category_outlined),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   // Note
//                   TextFormField(
//                     controller: _noteCtrl,
//                     decoration: const InputDecoration(
//                       labelText: 'Note (optional)',
//                       prefixIcon: Icon(Icons.sticky_note_2_outlined),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   // Date
//                   Row(
//                     children: [
//                       OutlinedButton.icon(
//                         onPressed: _pickDate,
//                         icon: const Icon(Icons.date_range),
//                         label: Text(df.format(_date)),
//                       ),
//                       const Spacer(),
//                       FilledButton.icon(
//                         onPressed: _submit,
//                         icon: const Icon(Icons.check),
//                         label: Text(widget.initial == null ? 'Add' : 'Save'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/transaction_model.dart';
import '../storage/storage_io.dart' as io
    if (dart.library.html) '../storage/storage_web.dart';

class AddEditTransactionSheet extends StatefulWidget {
  final TransactionModel? initial;
  const AddEditTransactionSheet({super.key, this.initial});

  static Future<void> importJson(BuildContext context,
      {required void Function(List<TransactionModel>) onImported}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null) return;

      String content;
      final path = result.files.single.path;
      if (path != null && path.isNotEmpty) {
        content = await io.readStringFromPath(path);
      } else if (result.files.single.bytes != null) {
        content = utf8.decode(result.files.single.bytes!);
      } else {
        throw 'Could not read file';
      }
      final List<dynamic> decoded = jsonDecode(content);
      final imported = decoded
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      onImported(imported);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Imported JSON file')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  @override
  State<AddEditTransactionSheet> createState() =>
      _AddEditTransactionSheetState();
}

class _AddEditTransactionSheetState extends State<AddEditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now(); // Added time field

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _type = init?.type ?? 'income';
    _amountCtrl.text = init?.amount.toStringAsFixed(2) ?? '';
    _noteCtrl.text = init?.note ?? '';
    if (init?.date != null) {
      _date = DateTime(init!.date.year, init.date.month, init.date.day);
      _time =
          TimeOfDay.fromDateTime(init.date); // Extract time from existing date
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (t != null) setState(() => _time = t);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amt = double.parse(_amountCtrl.text);

    final combinedDateTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    final t = TransactionModel(
      id: widget.initial?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      amount: amt,
      note: _noteCtrl.text.trim(),
      date: combinedDateTime, // Use combined date and time
      category: null, // Removed category selection
    );
    Navigator.pop(context, t);
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final df = DateFormat('dd MMM yyyy');
    final tf = DateFormat('HH:mm'); // Added time formatter

    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                widget.initial == null ? 'Add Transaction' : 'Edit Transaction',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
// Type
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                          value: 'income',
                          icon: Icon(Icons.trending_up),
                          label: Text('Income')),
                      ButtonSegment(
                          value: 'expense',
                          icon: Icon(Icons.trending_down),
                          label: Text('Expense')),
                    ],
                    selected: {_type},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => setState(() => _type = s.first),
                  ),
                  const SizedBox(height: 12),
// Amount
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter amount';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      if (double.parse(v) <= 0) return 'Amount must be > 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
// Note
                  TextFormField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      prefixIcon: Icon(Icons.sticky_note_2_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.date_range),
                          label: Text(df.format(_date)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(_time.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
// Submit button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check),
                      label: Text(widget.initial == null
                          ? 'Add Transaction'
                          : 'Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
