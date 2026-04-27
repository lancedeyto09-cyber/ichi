class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String image;
  final List<String> images;
  final List<String> tags; // ✅ NEW
  final int stock;
  final double rating;
  final int reviews;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.image,
    this.images = const [],
    this.tags = const [], // ✅ NEW
    required this.stock,
    required this.rating,
    required this.reviews,
    this.isFavorite = false,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: _toDouble(map['price']),
      category: (map['category'] ?? '').toString(),
      image: (map['image'] ?? '').toString(),
      images: _parseImages(map['images']),
      tags: _parseTags(map['tags']), // ✅ NEW
      stock: _toInt(map['stock']),
      rating: _toDouble(map['rating']),
      reviews: _toInt(map['reviews']),
      isFavorite: map['isFavorite'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image': image,
      'images': images,
      'tags': tags, // ✅ NEW
      'stock': stock,
      'rating': rating,
      'reviews': reviews,
      'isFavorite': isFavorite,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? image,
    List<String>? images,
    List<String>? tags, // ✅ NEW
    int? stock,
    double? rating,
    int? reviews,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      image: image ?? this.image,
      images: images ?? this.images,
      tags: tags ?? this.tags, // ✅ NEW
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static List<String> _parseImages(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    return [];
  }

  static List<String> _parseTags(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString().toLowerCase())
          .toList();
    }

    return [];
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
