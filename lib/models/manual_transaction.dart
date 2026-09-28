class ManualTransaction {
  final String id;

  final String type;

  final double amount;

  final String category;
final String note;
final int date;

  ManualTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date,
    };
  }

  factory ManualTransaction.fromMap(
    Map map,
  ) {
    return ManualTransaction(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      category: map['category'] ?? 'Food',
      note: map['note'],
      date: map['date'],
    );
  }
}