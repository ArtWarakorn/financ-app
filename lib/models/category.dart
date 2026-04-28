class Category {
  final String id;
  final String name;
  final String type;
  final String? icon;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    if (id.isEmpty) {
      throw Exception('Category has no valid id: $json');
    }
    return Category(
      id: id,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'expense',
      icon: json['icon']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'icon': icon,
    };
  }
}