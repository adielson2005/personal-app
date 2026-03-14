class Category {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String? imageUrl;
  final int order;
  final bool isActive;
  final int videoCount;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.imageUrl,
    this.order = 0,
    this.isActive = true,
    this.videoCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      icon: json['icon'],
      imageUrl: json['imageUrl'],
      order: json['order'] ?? 0,
      isActive: json['isActive'] ?? true,
      videoCount: json['videoCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'imageUrl': imageUrl,
      'order': order,
      'isActive': isActive,
      'videoCount': videoCount,
    };
  }

  // Ícones padrão para cada categoria
  String get defaultIcon {
    final icons = {
      'peito': '💪',
      'costas': '🔙',
      'perna': '🦵',
      'ombro': '🏋️',
      'biceps': '💪',
      'triceps': '💪',
      'cardio': '❤️',
      'abdomen': '🔥',
      'gluteo': '🍑',
      'outro': '⭐',
    };
    return icons[slug] ?? '⭐';
  }
}
