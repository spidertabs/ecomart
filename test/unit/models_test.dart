// test/unit/models_test.dart
//
// Pure unit tests for Product, CartItem, Order, and OrderItem.
// No Flutter framework needed — plain Dart.

import 'package:flutter_test/flutter_test.dart';
import 'package:ecomart/models/product.dart';
import 'package:ecomart/models/cart_item.dart';
import 'package:ecomart/models/order.dart';
import 'package:ecomart/models/order_item.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

Product _banana() => Product(
      id: 1,
      name: 'Banana',
      category: 'Fruits',
      price: 2500.0,
      imagePath: 'assets/images/banana.png',
      description: 'Fresh ripe bananas.',
      stock: 50,
    );

OrderItem _orderItem({int qty = 2, double price = 2500.0}) => OrderItem(
      id: 1,
      orderId: 10,
      productId: 1,
      productName: 'Banana',
      quantity: qty,
      priceAtPurchase: price,
    );

// ─── Product ─────────────────────────────────────────────────────────────────

void main() {
  group('Product', () {
    test('toMap() serialises all fields', () {
      final map = _banana().toMap();
      expect(map['id'], 1);
      expect(map['name'], 'Banana');
      expect(map['category'], 'Fruits');
      expect(map['price'], 2500.0);
      expect(map['image_path'], 'assets/images/banana.png');
      expect(map['stock'], 50);
    });

    test('fromMap() round-trips toMap()', () {
      final original = _banana();
      final copy = Product.fromMap(original.toMap());
      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.price, original.price);
      expect(copy.stock, original.stock);
    });

    test('fromMap() defaults imagePath to empty string when null', () {
      final map = _banana().toMap()..['image_path'] = null;
      final p = Product.fromMap(map);
      expect(p.imagePath, '');
    });

    test('fromMap() defaults stock to 0 when null', () {
      final map = _banana().toMap()..['stock'] = null;
      final p = Product.fromMap(map);
      expect(p.stock, 0);
    });

    test('fromMap() coerces int price to double', () {
      final map = _banana().toMap()..['price'] = 3000; // int, not double
      final p = Product.fromMap(map);
      expect(p.price, isA<double>());
      expect(p.price, 3000.0);
    });

    test('copyWith() replaces only specified fields', () {
      final updated = _banana().copyWith(price: 9999.0, stock: 1);
      expect(updated.price, 9999.0);
      expect(updated.stock, 1);
      expect(updated.name, 'Banana'); // unchanged
    });

    test('copyWith() with no args returns identical values', () {
      final original = _banana();
      final copy = original.copyWith();
      expect(copy.name, original.name);
      expect(copy.price, original.price);
    });
  });

  // ─── CartItem ───────────────────────────────────────────────────────────────

  group('CartItem', () {
    test('subtotal is price × quantity', () {
      final item = CartItem(
        id: 1,
        productId: 1,
        quantity: 3,
        product: _banana(),
      );
      expect(item.subtotal, 3 * 2500.0);
    });

    test('subtotal is 0.0 when product is null', () {
      final item = CartItem(id: 1, productId: 1, quantity: 5);
      expect(item.subtotal, 0.0);
    });

    test('toMap() excludes the joined product', () {
      final map = CartItem(id: 1, productId: 2, quantity: 4).toMap();
      expect(map.containsKey('product'), false);
      expect(map['product_id'], 2);
      expect(map['quantity'], 4);
    });

    test('fromMap() sets quantity and productId correctly', () {
      final item = CartItem.fromMap({'id': 7, 'product_id': 3, 'quantity': 2});
      expect(item.id, 7);
      expect(item.productId, 3);
      expect(item.quantity, 2);
    });

    test('fromMap() accepts an optional joined product', () {
      final item = CartItem.fromMap(
        {'id': 1, 'product_id': 1, 'quantity': 1},
        product: _banana(),
      );
      expect(item.product?.name, 'Banana');
      expect(item.subtotal, 2500.0);
    });
  });

  // ─── OrderItem ──────────────────────────────────────────────────────────────

  group('OrderItem', () {
    test('subtotal is priceAtPurchase × quantity', () {
      final item = _orderItem(qty: 3, price: 2500.0);
      expect(item.subtotal, 7500.0);
    });

    test('toMap() serialises all fields', () {
      final map = _orderItem().toMap();
      expect(map['order_id'], 10);
      expect(map['product_name'], 'Banana');
      expect(map['quantity'], 2);
      expect(map['price_at_purchase'], 2500.0);
    });

    test('fromMap() round-trips toMap()', () {
      final original = _orderItem();
      final copy = OrderItem.fromMap(original.toMap()..['id'] = 1);
      expect(copy.orderId, original.orderId);
      expect(copy.quantity, original.quantity);
      expect(copy.priceAtPurchase, original.priceAtPurchase);
    });

    test('fromMap() coerces int priceAtPurchase to double', () {
      final map = _orderItem().toMap()
        ..['id'] = 1
        ..['price_at_purchase'] = 2500; // int
      final item = OrderItem.fromMap(map);
      expect(item.priceAtPurchase, isA<double>());
    });
  });

  // ─── Order ──────────────────────────────────────────────────────────────────

  group('Order', () {
    test('default status is Pending', () {
      final order = Order(
        deliveryAddress: 'Kampala',
        customerName: 'Alice',
        phoneNumber: '0700000000',
        totalAmount: 5000.0,
        orderDate: '2025-01-01T10:00:00',
      );
      expect(order.status, 'Pending');
    });

    test('toMap() serialises all scalar fields', () {
      final order = Order(
        id: 5,
        deliveryAddress: 'Entebbe',
        customerName: 'Bob',
        phoneNumber: '0712345678',
        totalAmount: 12000.0,
        orderDate: '2025-06-15T08:30:00',
        status: 'Delivered',
      );
      final map = order.toMap();
      expect(map['id'], 5);
      expect(map['delivery_address'], 'Entebbe');
      expect(map['total_amount'], 12000.0);
      expect(map['status'], 'Delivered');
    });

    test('fromMap() round-trips toMap()', () {
      final original = Order(
        id: 3,
        deliveryAddress: 'Jinja',
        customerName: 'Carol',
        phoneNumber: '0756789012',
        totalAmount: 9500.0,
        orderDate: '2025-03-10T09:00:00',
        status: 'Pending',
      );
      final copy = Order.fromMap(original.toMap());
      expect(copy.deliveryAddress, original.deliveryAddress);
      expect(copy.totalAmount, original.totalAmount);
      expect(copy.status, original.status);
    });

    test('fromMap() defaults customerName to empty string when null', () {
      final map = {
        'id': 1,
        'delivery_address': 'Kampala',
        'customer_name': null,
        'phone_number': null,
        'total_amount': 1000.0,
        'order_date': '2025-01-01',
        'status': 'Pending',
      };
      final order = Order.fromMap(map);
      expect(order.customerName, '');
      expect(order.phoneNumber, '');
    });

    test('items list is mutable and starts empty by default', () {
      final order = Order(
        deliveryAddress: 'Mukono',
        customerName: 'Dan',
        phoneNumber: '0789',
        totalAmount: 3000,
        orderDate: '2025-01-01',
      );
      expect(order.items, isEmpty);
      order.items = [_orderItem()];
      expect(order.items.length, 1);
    });
  });
}