class Transaction {
  final String id;
  final String? userId;
  final String? categoryId;
  final String type;
  final double amount;
  final String? note;
  final DateTime transactionDate;
  final DateTime? createdAt;

  Transaction({
    required this.id,
    this.userId,
    this.categoryId,
    required this.type,
    required this.amount,
    this.note,
    required this.transactionDate,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    if (id.isEmpty) {
      throw Exception('Transaction has no valid id: $json');
    }
    return Transaction(
      id: id,
      userId: json['user_id']?.toString(),
      categoryId: json['category_id']?.toString(),
      type: json['type']?.toString() ?? 'expense',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      note: json['note']?.toString(),
      transactionDate: json['transaction_date'] != null
          ? DateTime.tryParse(json['transaction_date'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'note': note,
      'transaction_date':
          '${transactionDate.year}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}',
    };
  }
}