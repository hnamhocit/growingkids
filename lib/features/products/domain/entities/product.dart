import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String subtitle;
  final String priceLabel;
  final String imageUrl;
  final String? tag;
  final int backgroundColorValue;
  final String description;
  final List<String> highlights;

  const Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.priceLabel,
    required this.imageUrl,
    required this.backgroundColorValue,
    required this.description,
    required this.highlights,
    this.tag,
  });

  Color get backgroundColor => Color(backgroundColorValue);
}
