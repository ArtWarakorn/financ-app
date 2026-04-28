import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction; // null = เพิ่มใหม่

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _type = 'expense';
  String? _categoryId;
  DateTime _date = DateTime.now();
  List<Category> _categories = [];
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _type = t.type;
      _categoryId = t.categoryId;
      _date = t.transactionDate;
      _amountCtrl.text = t.amount.toString();
      _noteCtrl.text = t.note ?? '';
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _loading = true);
    try {
      final cats = await ApiService.getCategories();
      setState(() {
        _categories = cats;
        // กรองหมวดหมู่ตาม type เริ่มต้น
        if (_categoryId == null) {
          final filtered = cats.where((c) => c.type == _type).toList();
          if (filtered.isNotEmpty) _categoryId = filtered.first.id;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('โหลด category ล้มเหลว: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Category> get _filteredCategories =>
      _categories.where((c) => c.type == _type).toList();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('กรุณาเลือกหมวดหมู่')));
      return;
    }

    setState(() => _saving = true);
    try {
      final data = {
        'user_id': null,
        'category_id': _categoryId,
        'type': _type,
        'amount': double.parse(_amountCtrl.text.trim()),
        'note': _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        'transaction_date':
            '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
      };

      if (widget.transaction == null) {
        await ApiService.createTransaction(data);
      } else {
        await ApiService.updateTransaction(widget.transaction!.id, data);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.transaction == null ? 'เพิ่มรายการ' : 'แก้ไขรายการ'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── ประเภท รายรับ / รายจ่าย ──
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                            value: 'income',
                            label: Text('รายรับ'),
                            icon: Icon(Icons.arrow_downward)),
                        ButtonSegment(
                            value: 'expense',
                            label: Text('รายจ่าย'),
                            icon: Icon(Icons.arrow_upward)),
                      ],
                      selected: {_type},
                      onSelectionChanged: (s) {
                        setState(() {
                          _type = s.first;
                          _categoryId = null;
                          final filtered = _filteredCategories;
                          if (filtered.isNotEmpty) {
                            _categoryId = filtered.first.id;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── หมวดหมู่ ──
                    DropdownButtonFormField<String>(
                      value: _categoryId,
                      decoration: const InputDecoration(
                        labelText: 'หมวดหมู่',
                        border: OutlineInputBorder(),
                      ),
                      items: _filteredCategories
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                    '${c.icon != null ? '${c.icon} ' : ''}${c.name}'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _categoryId = v),
                      validator: (v) => v == null ? 'กรุณาเลือกหมวดหมู่' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── จำนวนเงิน ──
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'จำนวนเงิน (฿)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'กรุณากรอกจำนวนเงิน';
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) return 'จำนวนเงินต้องมากกว่า 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── วันที่ ──
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'วันที่',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(dateFmt.format(_date)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── หมายเหตุ ──
                    TextFormField(
                      controller: _noteCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'หมายเหตุ (ไม่บังคับ)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── ปุ่มบันทึก ──
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_saving ? 'กำลังบันทึก...' : 'บันทึก'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}