import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final String image;
  final List<String> images;
  final int stock;
  final double rating;
  final int reviews;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String sku;

  AdminProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.image,
    this.images = const [],
    required this.stock,
    required this.rating,
    required this.reviews,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.sku,
  });

  AdminProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? category,
    String? image,
    List<String>? images,
    int? stock,
    double? rating,
    int? reviews,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? sku,
  }) {
    return AdminProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      category: category ?? this.category,
      image: image ?? this.image,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      sku: sku ?? this.sku,
    );
  }

  factory AdminProduct.fromMap(Map<String, dynamic> map, String documentId) {
    return AdminProduct(
      id: (map['id'] ?? documentId).toString(),
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: _toDouble(map['price']),
      originalPrice:
          map['originalPrice'] == null ? null : _toDouble(map['originalPrice']),
      category: (map['category'] ?? '').toString(),
      image: (map['image'] ?? '').toString(),
      images: _toStringList(map['images']),
      stock: _toInt(map['stock']),
      rating: _toDouble(map['rating']),
      reviews: _toInt(map['reviews']),
      isActive: _toBool(map['isActive'], fallback: true),
      createdAt: _toDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _toDateTime(map['updatedAt']) ?? DateTime.now(),
      tags: _toStringList(map['tags']),
      sku: (map['sku'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'image': image,
      'images': images,
      'stock': stock,
      'rating': rating,
      'reviews': reviews,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'sku': sku,
    };
  }

  static List<String> _toStringList(dynamic value) {
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

  static bool _toBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    final normalized = value.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
