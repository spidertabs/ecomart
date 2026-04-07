// test/widget/checkout_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecomart/screens/checkout_screen.dart';
import 'package:ecomart/providers/cart_provider.dart';
import 'package:ecomart/models/cart_item.dart';
import 'package:ecomart/models/product.dart';

class _StubbedCartProvider extends CartProvider {
  _StubbedCartProvider() : super.forTesting();

  List<CartItem> _items = [];

  @override
  List<CartItem> get items => _items;
  @override
  bool get loading => false;
  @override
  double get totalPrice => _items.fold(0.0, (s, i) => s + i.subtotal);

  void seedItems(List<CartItem> items) {
    _items = items;
    notifyListeners();
  }

  @override
  Future<void> loadCart() async {}
  @override
  Future<void> clearCart() async {
    _items = [];
    notifyListeners();
  }
}

Product _p(int id) => Product(
    id: id, name: 'Item $id', category: 'T', price: 5000.0,
    imagePath: '', description: '', stock: 10);

CartItem _ci(int id) =>
    CartItem(id: id, productId: id, quantity: 1, product: _p(id));

Widget _buildCheckout(_StubbedCartProvider cart) =>
    ChangeNotifierProvider<CartProvider>.value(
      value: cart,
      child: const MaterialApp(home: CheckoutScreen()),
    );

void main() {
  late _StubbedCartProvider cart;

  setUp(() {
    cart = _StubbedCartProvider();
    cart.seedItems([_ci(1), _ci(2)]);
  });

  // Scrolls the button into view before tapping, preventing off-screen hit-test misses.
  Future<void> tapPlaceOrder(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Place Order'));
    await tester.tap(find.text('Place Order'));
    await tester.pump();
  }

  group('CheckoutScreen — renders', () {
    testWidgets('shows Order Summary section', (tester) async {
      await tester.pumpWidget(_buildCheckout(cart));
      expect(find.text('Order Summary'), findsOneWidget);
    });

    testWidgets('shows Delivery Details section', (tester) async {
      await tester.pumpWidget(_buildCheckout(cart));
      expect(find.text('Delivery Details'), findsOneWidget);
    });

    testWidgets('shows cart items in summary', (tester) async {
      await tester.pumpWidget(_buildCheckout(cart));
      expect(find.text('Item 1 × 1'), findsOneWidget);
      expect(find.text('Item 2 × 1'), findsOneWidget);
    });

    testWidgets('shows correct total price', (tester) async {
      await tester.pumpWidget(_buildCheckout(cart));
      expect(find.text('UGX 10000'), findsOneWidget);
    });

    testWidgets('Place Order button is present', (tester) async {
      await tester.pumpWidget(_buildCheckout(cart));
      expect(find.text('Place Order'), findsOneWidget);
    });
  });

  group('CheckoutScreen — form validation', () {
    testWidgets('shows Name required error when name is empty', (tester) async {
      await tester.pumpWidget(_buildCheckout(cart));
      await tapPlaceOrder(tester);
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('shows Phone required error when phone is empty', (tester) async {
      await tester.pumpWidget(_buildCheckout(cart));
      await tapPlaceOrder(tester);
      expect(find.text('Phone is required'), findsOneWidget);
    });

    testWidgets('shows Address required error when address is empty',
        (tester) async {
      await tester.pumpWidget(_buildCheckout(cart));
      await tapPlaceOrder(tester);
      expect(find.text('Address is required'), findsOneWidget);
    });

    testWidgets('all three errors shown simultaneously on empty submit',
        (tester) async {
      await tester.pumpWidget(_buildCheckout(cart));
      await tapPlaceOrder(tester);
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Phone is required'), findsOneWidget);
      expect(find.text('Address is required'), findsOneWidget);
    });

    testWidgets('no errors before first submit attempt', (tester) async {
      await tester.pumpWidget(_buildCheckout(cart));
      expect(find.text('Name is required'), findsNothing);
      expect(find.text('Phone is required'), findsNothing);
      expect(find.text('Address is required'), findsNothing);
    });

    testWidgets('name error clears after user types and resubmits',
        (tester) async {
      await tester.pumpWidget(_buildCheckout(cart));
      await tapPlaceOrder(tester); // trigger validation — all 3 errors appear
      expect(find.text('Name is required'), findsOneWidget);

      // Fill in the name field
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Full Name'), 'Bob');
      await tester.pump();

      // Resubmit via helper so button is scrolled into view first
      await tapPlaceOrder(tester);

      expect(find.text('Name is required'), findsNothing);
    });
  });
}