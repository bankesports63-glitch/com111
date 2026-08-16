import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComputerProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice; // for discount display
  final String category;
  final String brand;
  final String imagePath;
  final String emoji;
  final Color colorHex;
  final Map<String, String> specs; // technical specifications
  final bool isAvailable;
  final bool isFeatured;

  const ComputerProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.brand,
    this.imagePath = '',
    required this.emoji,
    required this.colorHex,
    this.specs = const {},
    this.isAvailable = true,
    this.isFeatured = false,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  int get discountPercent => hasDiscount
      ? (((originalPrice! - price) / originalPrice!) * 100).round()
      : 0;

  factory ComputerProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ComputerProduct(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: data['originalPrice'] != null ? (data['originalPrice'] as num).toDouble() : null,
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      imagePath: data['imagePath'] ?? '',
      emoji: data['emoji'] ?? '💻',
      colorHex: Color(data['colorHex'] ?? 0xFF00FF88),
      specs: Map<String, String>.from(data['specs'] ?? {}),
      isAvailable: data['isAvailable'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'brand': brand,
      'imagePath': imagePath,
      'emoji': emoji,
      'colorHex': colorHex.toARGB32(),
      'specs': specs,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
    };
  }
}
