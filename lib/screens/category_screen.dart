import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> _categories = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cats = await ApiService.getCategories();
      setState(() => _categories = cats);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('โหลดไม่สำเร็จ: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showForm({Category? cat}) async {
    final nameCtrl = TextEditingController(text: cat?.name ?? '');
    final iconCtrl = TextEditingController(text: cat?.icon ?? '');
    String type = cat?.type ?? 'expense';
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(cat == null ? 'เพิ่มหมวดหมู่' : 'แก้ไขหมวดหมู่'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'income', label: Text('รายรับ')),
                    ButtonSegment(value: 'expense', label: Text('รายจ่าย')),
                  ],
                  selected: {type},
                  onSelectionChanged: (s) =>
                      setStateDialog(() => type = s.first),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อหมวดหมู่',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'กรุณากรอกชื่อ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: iconCtrl,
                  decoration: const InputDecoration(
                    labelText: 'ไอคอน (emoji)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final data = {
                  'name': nameCtrl.text.trim(),
                  'type': type,
                  'icon': iconCtrl.text.trim().isEmpty
                      ? null
                      : iconCtrl.text.trim(),
                };
                try {
                  if (cat == null) {
                    await ApiService.createCategory(data);
                  } else {
                    await ApiService.updateCategory(cat.id, data);
                  }
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')),
                    );
                  }
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );

    if (result == true) _load();
  }

  Future<void> _delete(Category cat) async {
    // ตรวจสอบ id ก่อน
    if (cat.id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่พบ ID ของหมวดหมู่')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบ "${cat.name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteCategory(cat.id);
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ลบไม่สำเร็จ: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('หมวดหมู่')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i]; // ← capture แยกก่อนทุกครั้ง
                final isIncome = cat.type == 'income';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (isIncome ? Colors.green : Colors.red)
                        .withOpacity(0.15),
                    child: Text(
                      cat.icon ?? (isIncome ? '💰' : '💸'),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(cat.name),
                  subtitle: Text(isIncome ? 'รายรับ' : 'รายจ่าย'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showForm(cat: cat),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () => _delete(cat),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
