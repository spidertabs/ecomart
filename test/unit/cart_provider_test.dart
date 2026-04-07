// test/unit/cart_provider_test.dart
//
// Unit tests for CartProvider.
// Uses a hand-rolled fake for DBHelper so no real database is needed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecomart/models/cart_item.dart';
import 'package:ecomart/models/product.dart';

// ─── Fake DBHelper ────────────────────────────────────────────────────────────

class FakeDB {
  final List<CartItem> _cart = [];
  int _nextId = 1;

  Future<List<CartItem>> getCartItems() async => List.unmodifiable(_cart);

  Future<void> addToCart(int productId) async {
    final idx = _cart.indexWhere((i) => i.productId == productId);
    if (idx == -1) {
      _cart.add(CartItem(
        id: _nextId++,
        productId: productId,
        quantity: 1,
        product: _stubProduct(productId),
      ));
    } else {
      _cart[idx].quantity++;
    }
  }

  Future<void> updateCartItemQty(int cartItemId, int quantity) async {
    if (quantity <= 0) {
      _cart.removeWhere((i) => i.id == cartItemId);
    } else {
      final idx = _cart.indexWhere((i) => i.id == cartItemId);
      if (idx != -1) _cart[idx].quantity = quantity;
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    _cart.removeWhere((i) => i.id == cartItemId);
  }

  Future<void> clearCart() async => _cart.clear();

  Product _stubProduct(int id) => Product(
        id: id,
        name: 'Product $id',
        category: 'Test',
        price: 1000.0 * id,
        imagePath: '',
        description: '',
        stock: 10,
      );
}

// ─── Testable CartProvider ────────────────────────────────────────────────────

class TestableCartProvider extends ChangeNotifier {
  final FakeDB db;
  List<CartItem> _items = [];
  bool _loading = false;

  List<CartItem> get items => _items;
  bool get loading => _loading;
  int get totalItems => _items.fold(0, (s, i) => s + i.quantity);
  double get totalPrice => _items.fold(0.0, (s, i) => s + i.subtotal);

  TestableCartProvider(this.db) {
    loadCart();
  }

  Future<void> loadCart() async {
    _loading = true;
    notifyListeners();
    _items = await db.getCartItems();
    _loading = false;
    notifyListeners();
  }

  Future<void> addToCart(int productId) async {
    await db.addToCart(productId);
    await loadCart();
  }

  Future<void> updateQty(int cartItemId, int quantity) async {
    await db.updateCartItemQty(cartItemId, quantity);
    await loadCart();
  }

  Future<void> removeItem(int cartItemId) async {
    await db.removeFromCart(cartItemId);
    await loadCart();
  }

  Future<void> clearCart() async {
    await db.clearCart();
    _items = [];
    notifyListeners();
  }
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late FakeDB fakeDb;
  late TestableCartProvider cart;

  setUp(() {
    fakeDb = FakeDB();
    cart = TestableCartProvider(fakeDb);
  });

  group('CartProvider — initial state', () {
    test('starts empty after construction', () async {
      await Future.microtask(() {});
      expect(cart.items, isEmpty);
      expect(cart.totalItems, 0);
      expect(cart.totalPrice, 0.0);
      expect(cart.loading, false);
    });
  });

  group('CartProvider — addToCart', () {
    test('adds a new product to the cart', () async {
      await cart.addToCart(1);
      expect(cart.items.length, 1);
      expect(cart.items.first.productId, 1);
      expect(cart.items.first.quantity, 1);
    });

    test('increments quantity when the same product is added twice', () async {
      await cart.addToCart(1);
      await cart.addToCart(1);
      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 2);
    });

    test('adds distinct line-items for different products', () async {
      await cart.addToCart(1);
      await cart.addToCart(2);
      expect(cart.items.length, 2);
    });

    test('totalItems reflects sum of all quantities', () async {
      await cart.addToCart(1);
      await cart.addToCart(1);
      await cart.addToCart(2);
      expect(cart.totalItems, 3);
    });

    test('totalPrice is sum of (price × qty) for all items', () async {
      await cart.addToCart(1);
      await cart.addToCart(2);
      expect(cart.totalPrice, 1000.0 + 2000.0);
    });
  });

  group('CartProvider — updateQty', () {
    test('updates quantity of an existing item', () async {
      await cart.addToCart(1);
      final id = cart.items.first.id!;
      await cart.updateQty(id, 5);
      expect(cart.items.first.quantity, 5);
    });

    test('removes item when quantity set to 0', () async {
      await cart.addToCart(1);
      final id = cart.items.first.id!;
      await cart.updateQty(id, 0);
      expect(cart.items, isEmpty);
    });

    test('removes item when quantity is negative', () async {
      await cart.addToCart(1);
      final id = cart.items.first.id!;
      await cart.updateQty(id, -1);
      expect(cart.items, isEmpty);
    });
  });

  group('CartProvider — removeItem', () {
    test('removes the specified item', () async {
      await cart.addToCart(1);
      await cart.addToCart(2);
      final idToRemove = cart.items.first.id!;
      await cart.removeItem(idToRemove);
      expect(cart.items.length, 1);
      expect(cart.items.first.productId, isNot(idToRemove));
    });
  });

  group('CartProvider — clearCart', () {
    test('empties all items', () async {
      await cart.addToCart(1);
      await cart.addToCart(2);
      await cart.clearCart();
      expect(cart.items, isEmpty);
      expect(cart.totalItems, 0);
      expect(cart.totalPrice, 0.0);
    });
  });

  group('CartProvider — notifyListeners', () {
    test('notifies listeners when cart changes', () async {
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      await cart.addToCart(1);
      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });
}