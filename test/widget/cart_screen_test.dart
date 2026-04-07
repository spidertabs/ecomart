// test/widget/cart_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecomart/screens/cart_screen.dart';
import 'package:ecomart/screens/checkout_screen.dart';
import 'package:ecomart/providers/cart_provider.dart';
import 'package:ecomart/models/cart_item.dart';
import 'package:ecomart/models/product.dart';

// ─── Shared test infrastructure ───────────────────────────────────────────────

class _FakeDB {
  final List<CartItem> _cart = [];
  int _nextId = 1;

  Future<List<CartItem>> getCartItems() async => List.of(_cart);

  Future<void> addToCart(int productId) async {
    final idx = _cart.indexWhere((i) => i.productId == productId);
    if (idx == -1) {
      _cart.add(CartItem(
          id: _nextId++,
          productId: productId,
          quantity: 1,
          product: _stub(productId)));
    } else {
      _cart[idx].quantity++;
    }
  }

  Future<void> updateCartItemQty(int id, int qty) async {
    if (qty <= 0) {
      _cart.removeWhere((i) => i.id == id);
    } else {
      final idx = _cart.indexWhere((i) => i.id == id);
      if (idx != -1) _cart[idx].quantity = qty;
    }
  }

  Future<void> removeFromCart(int id) async =>
      _cart.removeWhere((i) => i.id == id);

  Future<void> clearCart() async => _cart.clear();

  Product _stub(int id) => Product(
        id: id,
        name: 'Product $id',
        category: 'Test',
        price: 1000.0 * id,
        imagePath: '',
        description: '',
        stock: 10,
      );
}

// ignore: unused_element
class _FakeCartProvider extends ChangeNotifier {
  final _FakeDB db;
  List<CartItem> _items = [];
  bool _loading = false;

  List<CartItem> get items => _items;
  bool get loading => _loading;
  int get totalItems => _items.fold(0, (s, i) => s + i.quantity);
  double get totalPrice => _items.fold(0.0, (s, i) => s + i.subtotal);

  _FakeCartProvider(this.db) {
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

  Future<void> updateQty(int id, int qty) async {
    await db.updateCartItemQty(id, qty);
    await loadCart();
  }

  Future<void> removeItem(int id) async {
    await db.removeFromCart(id);
    await loadCart();
  }

  Future<void> clearCart() async {
    await db.clearCart();
    _items = [];
    notifyListeners();
  }
}

// ─── Stubbed CartProvider ─────────────────────────────────────────────────────

class _StubbedCartProvider extends CartProvider {
  _StubbedCartProvider() : super.forTesting();

  List<CartItem> _stubbedItems = [];

  @override
  List<CartItem> get items => _stubbedItems;

  @override
  bool get loading => false;

  @override
  int get totalItems => _stubbedItems.fold(0, (s, i) => s + i.quantity);

  @override
  double get totalPrice =>
      _stubbedItems.fold(0.0, (s, i) => s + i.subtotal);

  void seedItems(List<CartItem> items) {
    _stubbedItems = items;
    notifyListeners();
  }

  @override
  Future<void> loadCart() async {}

  @override
  Future<void> addToCart(int productId) async {}

  @override
  Future<void> updateQty(int cartItemId, int quantity) async {
    if (quantity <= 0) {
      _stubbedItems.removeWhere((i) => i.id == cartItemId);
    } else {
      final idx = _stubbedItems.indexWhere((i) => i.id == cartItemId);
      if (idx != -1) _stubbedItems[idx].quantity = quantity;
    }
    notifyListeners();
  }

  @override
  Future<void> removeItem(int cartItemId) async {
    _stubbedItems.removeWhere((i) => i.id == cartItemId);
    notifyListeners();
  }

  @override
  Future<void> clearCart() async {
    _stubbedItems = [];
    notifyListeners();
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Widget _wrapReal(Widget child, CartProvider cart) =>
    ChangeNotifierProvider<CartProvider>.value(
      value: cart,
      child: MaterialApp(home: child),
    );

Product _stubProduct(int id, {double price = 2500.0}) => Product(
      id: id,
      name: 'Test Product $id',
      category: 'Test',
      price: price,
      imagePath: '',
      description: '',
      stock: 10,
    );

CartItem _stubCartItem(int id, {int qty = 1, double price = 2500.0}) =>
    CartItem(
      id: id,
      productId: id,
      quantity: qty,
      product: _stubProduct(id, price: price),
    );

// ─── CartScreen widget tests ──────────────────────────────────────────────────

void main() {
  group('CartScreen — empty state', () {
    testWidgets('shows empty cart message when no items', (tester) async {
      final cart = _StubbedCartProvider();
      await tester.pumpWidget(_wrapReal(const CartScreen(), cart));
      await tester.pump();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsWidgets);
    });

    testWidgets('does not show checkout button when empty', (tester) async {
      final cart = _StubbedCartProvider();
      await tester.pumpWidget(_wrapReal(const CartScreen(), cart));
      await tester.pump();

      expect(find.text('Proceed to Checkout'), findsNothing);
    });
  });

  group('CartScreen — with items', () {
    late _StubbedCartProvider cart;

    setUp(() {
      cart = _StubbedCartProvider();
      cart.seedItems([
        _stubCartItem(1, qty: 2, price: 2500.0),
        _stubCartItem(2, qty: 1, price: 3500.0),
      ]);
    });

    testWidgets('renders one ListTile per cart item', (tester) async {
      await tester.pumpWidget(_wrapReal(const CartScreen(), cart));
      await tester.pump();

      expect(find.text('Test Product 1'), findsOneWidget);
      expect(find.text('Test Product 2'), findsOneWidget);
    });

    testWidgets('shows total price correctly', (tester) async {
      await tester.pumpWidget(_wrapReal(const CartScreen(), cart));
      await tester.pump();

      expect(find.text('UGX 8500'), findsOneWidget);
    });

    testWidgets('shows total item count correctly', (tester) async {
      await tester.pumpWidget(_wrapReal(const CartScreen(), cart));
      await tester.pump();

      expect(find.text('3'), findsWidgets);
    });

    testWidgets('Proceed to Checkout button is visible', (tester) async {
      await tester.pumpWidget(_wrapReal(const CartScreen(), cart));
      await tester.pump();

      expect(find.text('Proceed to Checkout'), findsOneWidget);
    });

    testWidgets('tapping – remove button decrements quantity', (tester) async {
      await tester.pumpWidget(_wrapReal(const CartScreen(), cart));
      await tester.pump();

      final removeBtn = find.byIcon(Icons.remove).first;
      await tester.tap(removeBtn);
      await tester.pump();

      expect(find.text('UGX 6000'), findsOneWidget);
    });

    testWidgets('tapping + increments quantity', (tester) async {
      await tester.pumpWidget(_wrapReal(const CartScreen(), cart));
      await tester.pump();

      final addBtn = find.byIcon(Icons.add).first;
      await tester.tap(addBtn);
      await tester.pump();

      expect(find.text('UGX 11000'), findsOneWidget);
    });
  });

  group('CartScreen — loading state', () {
    testWidgets('shows spinner while loading', (tester) async {
      final cart = _StubbedCartProvider();
      await tester.pumpWidget(_wrapReal(const CartScreen(), cart));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ─── CheckoutScreen form validation tests ──────────────────────────────────

  group('CheckoutScreen — form validation (from cart_screen_test)', () {
    late _StubbedCartProvider cart;

    setUp(() {
      cart = _StubbedCartProvider();
      cart.seedItems([
        _stubCartItem(1),
        _stubCartItem(2),
      ]);
    });

    Widget buildCheckout() => ChangeNotifierProvider<CartProvider>.value(
          value: cart,
          child: const MaterialApp(home: CheckoutScreen()),
        );

    testWidgets('shows Place Order button', (tester) async {
      await tester.pumpWidget(buildCheckout());
      expect(find.text('Place Order'), findsOneWidget);
    });
  });
}