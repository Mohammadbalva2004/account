// class TransactionModel {
//   final String id;
//   final String type; // 'income' or 'expense'
//   final double amount;
//   final String note;
//   final DateTime date;
//   final String? category;
//
//   TransactionModel({
//     required this.id,
//     required this.type,
//     required this.amount,
//     required this.note,
//     required this.date,
//     this.category,
//   });
//
//   TransactionModel copyWith({
//     String? id,
//     String? type,
//     double? amount,
//     String? note,
//     DateTime? date,
//     String? category,
//   }) {
//     return TransactionModel(
//       id: id ?? this.id,
//       type: type ?? this.type,
//       amount: amount ?? this.amount,
//       note: note ?? this.note,
//       date: date ?? this.date,
//       category: category ?? this.category,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'type': type,
//         'amount': amount,
//         'note': note,
//         'date': date.toIso8601String(),
//         'category': category,
//       };
//
//   static TransactionModel fromJson(Map<String, dynamic> j) => TransactionModel(
//         id: j['id'] as String,
//         type: j['type'] as String,
//         amount: (j['amount'] as num).toDouble(),
//         note: j['note'] as String,
//         date: DateTime.parse(j['date'] as String),
//         category: j['category'] as String?,
//       );
// }
//
// // Some sample categories you can use in UI
// const kCategories = <String>[
//   'Salary',
//   'Business',
//   'Food',
//   'Bills',
//   'Rent',
//   'Travel',
//   'Shopping',
//   'Health',
//   'Other',
// ];

class TransactionModel {
  final String id;
  final String type; // 'income' or 'expense'
  final double amount;
  final String note;
  final DateTime date;
  final String? category;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.note,
    required this.date,
    this.category,
  });

  TransactionModel copyWith({
    String? id,
    String? type,
    double? amount,
    String? note,
    DateTime? date,
    String? category,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'amount': amount,
    'note': note,
    'date': date.toIso8601String(),
    'category': category,
  };

  static TransactionModel fromJson(Map<String, dynamic> j) => TransactionModel(
    id: j['id'] as String,
    type: j['type'] as String,
    amount: (j['amount'] as num).toDouble(),
    note: j['note'] as String,
    date: DateTime.parse(j['date'] as String),
    category: j['category'] as String?,
  );
}

// Removed categories as per user request - no more predefined categories
const kCategories = <String>[];
