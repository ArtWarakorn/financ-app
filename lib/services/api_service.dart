import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/transaction.dart';

class ApiService {
  //URL ของ Next.js server
  static const String baseUrl = 'https://financ-api.vercel.app';

  // ── TRANSACTIONS ──────────────────────────────────────────

  static Future<List<Transaction>> getTransactions() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/transactions'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load transactions: ${response.body}');
  }

  static Future<Transaction> createTransaction(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Transaction.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to create transaction: ${response.body}');
  }

  static Future<Transaction> updateTransaction(
      String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/transactions/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Transaction.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to update transaction: ${response.body}');
  }

  static Future<void> deleteTransaction(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/transactions/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction: ${response.body}');
    }
  }

  // ── CATEGORIES ────────────────────────────────────────────

  static Future<List<Category>> getCategories() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/categorise'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load categories: ${response.body}');
  }

  static Future<Category> createCategory(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/categorise'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Category.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to create category: ${response.body}');
  }

  static Future<Category> updateCategory(
      String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/categorise/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Category.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to update category: ${response.body}');
  }

  static Future<void> deleteCategory(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/categorise/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete category: ${response.body}');
    }
  }
}