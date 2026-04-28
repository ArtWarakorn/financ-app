class Transaction {
  final String id;
  final String? userId;
  final String? categoryId;
  final String type; // 'income' | 'expense'
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
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      categoryId: json['category_id'] as String?,
      type: json['type'] as String,
      amount: double.parse(json['amount'].toString()),
      note: json['note'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
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