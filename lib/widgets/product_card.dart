import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF1F8E9),
              child: const Icon(
                Icons.shopping_basket,
                size: 56,
                color: Color(0xFF81C784),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
            child: Text(
              'UGX ${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Consumer<CartProvider>(
              builder: (context, cart, _) {
                final inCart = cart.items.any(
                    (i) => i.productId == product.id);
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await cart.addToCart(product.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${product.name} added to cart'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      inCart ? Icons.add_shopping_cart : Icons.add,
                      size: 16,
                    ),
                    label: Text(
                      inCart ? 'Add More' : 'Add to Cart',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
