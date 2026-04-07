import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _loading = false;

  List<CartItem> get items => _items;
  bool get loading => _loading;

  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  CartProvider() {
    loadCart();
  }

  /// Constructor for testing only — skips loadCart so DBHelper is never called.
  CartProvider.forTesting();

  Future<void> loadCart() async {
    _loading = true;
    notifyListeners();
    _items = await DBHelper.instance.getCartItems();
    _loading = false;
    notifyListeners();
  }

  Future<void> addToCart(int productId) async {
    await DBHelper.instance.addToCart(productId);
    await loadCart();
  }

  Future<void> updateQty(int cartItemId, int quantity) async {
    await DBHelper.instance.updateCartItemQty(cartItemId, quantity);
    await loadCart();
  }

  Future<void> removeItem(int cartItemId) async {
    await DBHelper.instance.removeFromCart(cartItemId);
    await loadCart();
  }

  Future<void> clearCart() async {
    await DBHelper.instance.clearCart();
    _items = [];
    notifyListeners();
  }
}
