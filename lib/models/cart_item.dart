import 'product.dart';

class CartItem {
  final int? id;
  final int productId;
  int quantity;
  Product? product; // joined from products table

  CartItem({
    this.id,
    required this.productId,
    required this.quantity,
    this.product,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, {Product? product}) {
    return CartItem(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
      product: product,
    );
  }

  double get subtotal => (product?.price ?? 0) * quantity;
}
