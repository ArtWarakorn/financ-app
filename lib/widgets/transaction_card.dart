import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final List<Category> categories;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'th_TH');
    final dateFmt = DateFormat('dd MMM yyyy', 'th_TH');
    final isIncome = transaction.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;

    final category = categories.where((c) => c.id == transaction.categoryId);
    final categoryName = category.isNotEmpty
        ? category.first.name
        : 'ไม่มีหมวดหมู่';
    final categoryIcon = category.isNotEmpty ? category.first.icon : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Text(
            categoryIcon ?? (isIncome ? '💰' : '💸'),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${dateFmt.format(transaction.transactionDate)}'
          '${transaction.note != null && transaction.note!.isNotEmpty ? ' • ${transaction.note}' : ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}฿${fmt.format(transaction.amount)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') {
                  assert(
                    transaction.id.isNotEmpty,
                    'Transaction ID must not be empty',
                  );
                  onDelete();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('แก้ไข')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('ลบ', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
