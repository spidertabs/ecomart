class Product {
  final int? id;
  final String name;
  final String category;
  final double price;
  final String imagePath;
  final String description;
  final int stock;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'image_path': imagePath,
      'description': description,
      'stock': stock,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      imagePath: map['image_path'] as String? ?? '',
      description: map['description'] as String? ?? '',
      stock: map['stock'] as int? ?? 0,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    String? imagePath,
    String? description,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      stock: stock ?? this.stock,
    );
  }
}
