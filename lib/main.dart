import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'model/transaction_model.dart';
import 'storage/storage_io.dart'
    if (dart.library.html) 'storage/storage_web.dart' as platform_storage;
import 'widgets/summary_cards.dart';
import 'widgets/filter_bar.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/add_edit_transaction_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF6750A4),
      scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        surfaceTintColor: Colors.transparent,
        elevation: 1,
      ),
    );

    return MaterialApp(
      title: 'Local Finance Pro',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final platform_storage.FileStorage storage;

  List<TransactionModel> _all = [];
  String _typeFilter = 'all';
  DateTimeRange? _range;
  String _search = '';

  @override
  void initState() {
    super.initState();
    storage = platform_storage.FileStorage();
    _load();
  }

  Future<void> _load() async {
    final list = await storage.readTransactions();
    if (!mounted) return;
    setState(() => _all = list..sort((a, b) => b.date.compareTo(a.date)));
  }

  Future<void> _save() async {
    await storage.writeTransactions(_all);
  }

  List<TransactionModel> get _filtered {
    return _all.where((t) {
      if (_typeFilter != 'all' && t.type != _typeFilter) return false;
      if (_range != null) {
        final s = DateUtils.dateOnly(_range!.start);
        final e = DateUtils.dateOnly(_range!.end);
        final d = DateUtils.dateOnly(t.date);
        if (d.isBefore(s) || d.isAfter(e)) return false;
      }
      if (_search.trim().isNotEmpty) {
        final q = _search.toLowerCase();
        final hay = '${t.note} ${t.category ?? ''}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double get _totalIncome =>
      _all.where((t) => t.type == 'income').fold(0.0, (p, e) => p + e.amount);
  double get _totalExpense =>
      _all.where((t) => t.type == 'expense').fold(0.0, (p, e) => p + e.amount);

  String currency(double v) {
    final f =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    return f.format(v);
  }

  Future<void> _exportJson() async {
    try {
      await storage.exportJson(_all);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                kIsWeb ? 'JSON downloaded' : 'JSON exported to documents')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _exportPdf() async {
    try {
      final pdf = pw.Document();
      final DateFormat df = DateFormat('yyyy-MM-dd HH:mm');

      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(level: 0, child: pw.Text('Transactions Export')),
            pw.Paragraph(text: 'Generated: ${df.format(DateTime.now())}'),
            pw.Table.fromTextArray(
              headers: ['Type', 'Amount', 'Category', 'Note', 'Date'],
              data: _all
                  .map((t) => [
                        t.type,
                        t.amount.toStringAsFixed(2),
                        t.category ?? '-',
                        t.note,
                        df.format(t.date),
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 12),
            pw.Paragraph(
                text: 'Total Income: ${_totalIncome.toStringAsFixed(2)}'),
            pw.Paragraph(
                text: 'Total Expense: ${_totalExpense.toStringAsFixed(2)}'),
            pw.Paragraph(
                text:
                    'Balance: ${(_totalIncome - _totalExpense).toStringAsFixed(2)}'),
          ],
        ),
      );

      final bytes = await pdf.save();
      final filename =
          'transactions_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await storage.savePdf(bytes, filename);

      try {
        await Printing.layoutPdf(onLayout: (_) async => bytes);
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(kIsWeb ? 'PDF downloaded' : 'PDF saved to documents')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
    }
  }

  void _openAdd([TransactionModel? edit]) async {
    final result = await showModalBottomSheet<TransactionModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddEditTransactionSheet(initial: edit),
    );
    if (result == null) return;

    setState(() {
      if (edit == null) {
        _all.insert(0, result);
      } else {
        final idx = _all.indexWhere((e) => e.id == edit.id);
        if (idx != -1) _all[idx] = result.copyWith(id: edit.id);
      }
      _all.sort((a, b) => b.date.compareTo(a.date));
    });
    await _save();
  }

  Future<void> _delete(TransactionModel t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Remove transaction?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Yes')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _all.removeWhere((e) => e.id == t.id));
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final cs = Theme.of(context).colorScheme;
    //  Added responsive breakpoints and screen size detection
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final isMobile = screenWidth < 600;

    //  Responsive padding based on screen size
    final horizontalPadding = isMobile
        ? 12.0
        : isTablet
            ? 24.0
            : 32.0;
    final verticalSpacing = isMobile ? 8.0 : 12.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Local Finance Pro',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Export PDF',
            onPressed: _exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (v) async {
              if (v == 'export_json') await _exportJson();
              if (v == 'clear') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text('Clear all transactions?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('No')),
                      TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Yes')),
                    ],
                  ),
                );
                if (ok == true) {
                  setState(() => _all = []);
                  await _save();
                }
              }
              if (v == 'import') {
                await AddEditTransactionSheet.importJson(context,
                    onImported: (list) async {
                  setState(() {
                    _all = [...list, ..._all];
                    _all.sort((a, b) => b.date.compareTo(a.date));
                  });
                  await _save();
                });
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'import', child: Text('Import JSON')),
              PopupMenuItem(value: 'export_json', child: Text('Export JSON')),
              PopupMenuItem(value: 'clear', child: Text('Clear All')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            //  Added LayoutBuilder for better responsive handling
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  horizontalPadding, verticalSpacing, horizontalPadding, 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - verticalSpacing,
                  maxWidth: isDesktop ? 1200 : double.infinity,
                ),
                child: Column(
                  children: [
                    //  Responsive summary cards with proper constraints
                    SummaryCards(
                      income: _totalIncome,
                      expense: _totalExpense,
                      balance: _totalIncome - _totalExpense,
                      currency: currency,
                      isCompact: isMobile,
                    ),

                    SizedBox(height: verticalSpacing),

                    //  Responsive filter bar
                    FilterBar(
                      type: _typeFilter,
                      onTypeChanged: (t) => setState(() => _typeFilter = t),
                      range: _range,
                      onPickRange: (r) => setState(() => _range = r),
                      onClearRange: () => setState(() => _range = null),
                      onSearch: (q) => setState(() => _search = q),
                      isCompact: isMobile,
                    ),

                    SizedBox(height: verticalSpacing),

                    //  Responsive transaction list with proper height constraints
                    SizedBox(
                      height:
                          constraints.maxHeight - 280 - (verticalSpacing * 3),
                      child: Card(
                        child: filtered.isEmpty
                            ? Center(
                                child: Padding(
                                  padding:
                                      EdgeInsets.all(isMobile ? 20.0 : 28.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        size: isMobile ? 48 : 64,
                                        color: cs.outline,
                                      ),
                                      SizedBox(height: isMobile ? 12 : 16),
                                      Text(
                                        'No transactions yet',
                                        style: GoogleFonts.inter(
                                          fontSize: isMobile ? 16 : 18,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.all(isMobile ? 6 : 8),
                                itemBuilder: (_, i) {
                                  final t = filtered[i];
                                  return TransactionTile(
                                    t: t,
                                    onTap: () => _openAdd(t),
                                    onDelete: () => _delete(t),
                                    currency: currency,
                                    isCompact: isMobile,
                                  );
                                },
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: cs.outlineVariant,
                                  indent: isMobile ? 12 : 16,
                                  endIndent: isMobile ? 12 : 16,
                                ),
                                itemCount: filtered.length,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      //  Responsive FAB positioning
      floatingActionButton: isDesktop
          ? Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 70),
              child: FloatingActionButton.extended(
                onPressed: () => _openAdd(),
                icon: const Icon(Icons.add),
                label: const Text('Add Transaction'),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
              child: FloatingActionButton(
                onPressed: () => _openAdd(),
                child: const Icon(Icons.add),
              ),
            ),
      floatingActionButtonLocation: isDesktop
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.endFloat,
    );
  }
}
