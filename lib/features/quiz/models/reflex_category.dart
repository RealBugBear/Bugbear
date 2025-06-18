class ReflexCategory {
  final String id;
  final String name;

  ReflexCategory({required this.id, required this.name});

  factory ReflexCategory.fromJson(Map<String, dynamic> json) {
    return ReflexCategory(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
