class Category {
  final String id;
  final String name;
  final String type; // 'income' | 'expense'
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
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
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