// test/integration/db_helper_test.dart
//
// Integration tests for DBHelper against a real (in-memory) SQLite database.
// Uses sqflite_common_ffi so this runs on Linux / CI without an emulator.
//
// ─── Setup required ──────────────────────────────────────────────────────────
// Add to pubspec.yaml dev_dependencies:
//   sqflite_common_ffi: ^2.3.4
//
// Then import it in your test setup (done here via sqfliteTestInit below).

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ecomart/models/cart_item.dart';
import 'package:ecomart/models/product.dart';

// ─── Minimal in-process DBHelper ─────────────────────────────────────────────
// We duplicate just enough of DBHelper to test against a fresh in-memory DB
// for each test group — avoiding the singleton state that would bleed between
// tests if we used DBHelper.instance directly.

import 'package:ecomart/models/order.dart';
import 'package:ecomart/models/order_item.dart';

class TestDB {
  late Database _db;

  Future<void> open() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> close() => _db.close();

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, category TEXT NOT NULL,
        price REAL NOT NULL, image_path TEXT,
        description TEXT, stock INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL, quantity INTEGER NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        delivery_address TEXT NOT NULL, customer_name TEXT,
        phone_number TEXT, total_amount REAL NOT NULL,
        order_date TEXT NOT NULL, status TEXT DEFAULT 'Pending'
      )
    ''');
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL, product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL, quantity INTEGER NOT NULL,
        price_at_purchase REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id)
      )
    ''');
  }

  // ─── Products ──────────────────────────────────────────────────────────────

  Future<int> insertProduct(Map<String, dynamic> data) =>
      _db.insert('products', data);

  Future<List<Product>> getAllProducts() async {
    final rows = await _db.query('products');
    return rows.map(Product.fromMap).toList();
  }

  Future<List<Product>> getProductsByCategory(String cat) async {
    final rows = await _db.query('products',
        where: 'category = ?', whereArgs: [cat]);
    return rows.map(Product.fromMap).toList();
  }

  Future<List<Product>> searchProducts(String q) async {
    final rows = await _db.query('products',
        where: 'name LIKE ? OR category LIKE ?',
        whereArgs: ['%$q%', '%$q%']);
    return rows.map(Product.fromMap).toList();
  }

  Future<List<String>> getCategories() async {
    final rows = await _db
        .rawQuery('SELECT DISTINCT category FROM products ORDER BY category');
    return rows.map((r) => r['category'] as String).toList();
  }

  // ─── Cart ──────────────────────────────────────────────────────────────────

  Future<List<CartItem>> getCartItems() async {
    final rows = await _db.rawQuery('''
      SELECT c.id, c.product_id, c.quantity,
             p.name, p.category, p.price, p.image_path, p.description, p.stock
      FROM cart_items c JOIN products p ON c.product_id = p.id
    ''');
    return rows.map((r) {
      final product = Product(
        id: r['product_id'] as int,
        name: r['name'] as String,
        category: r['category'] as String,
        price: (r['price'] as num).toDouble(),
        imagePath: r['image_path'] as String? ?? '',
        description: r['description'] as String? ?? '',
        stock: r['stock'] as int? ?? 0,
      );
      return CartItem(
        id: r['id'] as int,
        productId: r['product_id'] as int,
        quantity: r['quantity'] as int,
        product: product,
      );
    }).toList();
  }

  Future<void> addToCart(int productId) async {
    final existing = await _db.query('cart_items',
        where: 'product_id = ?', whereArgs: [productId]);
    if (existing.isEmpty) {
      await _db.insert(
          'cart_items', {'product_id': productId, 'quantity': 1});
    } else {
      final current = existing.first['quantity'] as int;
      await _db.update('cart_items', {'quantity': current + 1},
          where: 'product_id = ?', whereArgs: [productId]);
    }
  }

  Future<void> updateCartItemQty(int cartItemId, int quantity) async {
    if (quantity <= 0) {
      await _db.delete('cart_items',
          where: 'id = ?', whereArgs: [cartItemId]);
    } else {
      await _db.update('cart_items', {'quantity': quantity},
          where: 'id = ?', whereArgs: [cartItemId]);
    }
  }

  Future<void> removeFromCart(int cartItemId) async =>
      _db.delete('cart_items', where: 'id = ?', whereArgs: [cartItemId]);

  Future<void> clearCart() async => _db.delete('cart_items');

  // ─── Orders ────────────────────────────────────────────────────────────────

  Future<int> placeOrder({
    required String deliveryAddress,
    required String customerName,
    required String phoneNumber,
    required double totalAmount,
    required List<CartItem> cartItems,
  }) async {
    final orderId = await _db.insert('orders', {
      'delivery_address': deliveryAddress,
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'total_amount': totalAmount,
      'order_date': DateTime.now().toIso8601String(),
      'status': 'Pending',
    });
    final batch = _db.batch();
    for (final item in cartItems) {
      batch.insert('order_items', {
        'order_id': orderId,
        'product_id': item.productId,
        'product_name': item.product?.name ?? '',
        'quantity': item.quantity,
        'price_at_purchase': item.product?.price ?? 0,
      });
    }
    await batch.commit(noResult: true);
    await clearCart();
    return orderId;
  }

  Future<List<Order>> getOrders() async {
    final orderMaps =
        await _db.query('orders', orderBy: 'order_date DESC');
    final orders = orderMaps.map(Order.fromMap).toList();
    for (final order in orders) {
      final itemMaps = await _db.query('order_items',
          where: 'order_id = ?', whereArgs: [order.id]);
      order.items = itemMaps.map(OrderItem.fromMap).toList();
    }
    return orders;
  }
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late TestDB db;

  // Seed a product and return its inserted id.
  Future<int> seedProduct({
    String name = 'Banana',
    String category = 'Fruits',
    double price = 2500.0,
    int stock = 50,
  }) =>
      db.insertProduct({
        'name': name,
        'category': category,
        'price': price,
        'image_path': '',
        'description': '',
        'stock': stock,
      });

  setUp(() async {
    db = TestDB();
    await db.open();
  });

  tearDown(() => db.close());

  // ─── Products ──────────────────────────────────────────────────────────────

  group('DBHelper — products', () {
    test('getAllProducts returns all inserted rows', () async {
      await seedProduct(name: 'Banana');
      await seedProduct(name: 'Mango', category: 'Fruits');
      final products = await db.getAllProducts();
      expect(products.length, 2);
    });

    test('getProductsByCategory filters correctly', () async {
      await seedProduct(name: 'Milk', category: 'Dairy');
      await seedProduct(name: 'Banana', category: 'Fruits');
      final dairy = await db.getProductsByCategory('Dairy');
      expect(dairy.length, 1);
      expect(dairy.first.name, 'Milk');
    });

    test('getProductsByCategory returns empty for unknown category', () async {
      await seedProduct(name: 'Banana');
      final result = await db.getProductsByCategory('NonExistent');
      expect(result, isEmpty);
    });

    test('searchProducts matches by name (case-insensitive LIKE)', () async {
      await seedProduct(name: 'Sukuma Wiki');
      await seedProduct(name: 'Sugar');
      final results = await db.searchProducts('suk');
      expect(results.length, 1);
      expect(results.first.name, 'Sukuma Wiki');
    });

    test('searchProducts matches by category', () async {
      await seedProduct(name: 'Posho', category: 'Staples');
      await seedProduct(name: 'Rice', category: 'Staples');
      await seedProduct(name: 'Banana', category: 'Fruits');
      final results = await db.searchProducts('Staples');
      expect(results.length, 2);
    });

    test('searchProducts returns empty when nothing matches', () async {
      await seedProduct(name: 'Banana');
      expect(await db.searchProducts('xyz'), isEmpty);
    });

    test('getCategories returns distinct sorted categories', () async {
      await seedProduct(category: 'Fruits');
      await seedProduct(category: 'Dairy');
      await seedProduct(category: 'Fruits'); // duplicate
      final cats = await db.getCategories();
      expect(cats, ['Dairy', 'Fruits']); // distinct + alphabetical
    });
  });

  // ─── Cart ──────────────────────────────────────────────────────────────────

  group('DBHelper — cart', () {
    test('addToCart inserts a new row with quantity 1', () async {
      final pid = await seedProduct();
      await db.addToCart(pid);
      final items = await db.getCartItems();
      expect(items.length, 1);
      expect(items.first.quantity, 1);
    });

    test('addToCart increments quantity for duplicate product', () async {
      final pid = await seedProduct();
      await db.addToCart(pid);
      await db.addToCart(pid);
      final items = await db.getCartItems();
      expect(items.length, 1);
      expect(items.first.quantity, 2);
    });

    test('getCartItems joins product name and price', () async {
      final pid = await seedProduct(name: 'Mango', price: 3500.0);
      await db.addToCart(pid);
      final items = await db.getCartItems();
      expect(items.first.product?.name, 'Mango');
      expect(items.first.product?.price, 3500.0);
    });

    test('updateCartItemQty updates correctly', () async {
      final pid = await seedProduct();
      await db.addToCart(pid);
      final item = (await db.getCartItems()).first;
      await db.updateCartItemQty(item.id!, 7);
      expect((await db.getCartItems()).first.quantity, 7);
    });

    test('updateCartItemQty with 0 removes the row', () async {
      final pid = await seedProduct();
      await db.addToCart(pid);
      final item = (await db.getCartItems()).first;
      await db.updateCartItemQty(item.id!, 0);
      expect(await db.getCartItems(), isEmpty);
    });

    test('removeFromCart deletes only that item', () async {
      final pid1 = await seedProduct(name: 'A');
      final pid2 = await seedProduct(name: 'B');
      await db.addToCart(pid1);
      await db.addToCart(pid2);
      final items = await db.getCartItems();
      await db.removeFromCart(items.first.id!);
      expect((await db.getCartItems()).length, 1);
    });

    test('clearCart removes everything', () async {
      final pid = await seedProduct();
      await db.addToCart(pid);
      await db.clearCart();
      expect(await db.getCartItems(), isEmpty);
    });
  });

  // ─── Orders ────────────────────────────────────────────────────────────────

  group('DBHelper — orders', () {
    Future<List<CartItem>> cartWith(int pid, {int qty = 2}) async {
      await db.addToCart(pid);
      if (qty > 1) {
        await db.updateCartItemQty(
        (await db.getCartItems()).first.id!, qty);
      }
      return db.getCartItems();
    }

    test('placeOrder inserts order and order_items', () async {
      final pid = await seedProduct(price: 3000.0);
      final cartItems = await cartWith(pid, qty: 2);
      final orderId = await db.placeOrder(
        deliveryAddress: 'Kampala',
        customerName: 'Alice',
        phoneNumber: '0700000000',
        totalAmount: 6000.0,
        cartItems: cartItems,
      );
      expect(orderId, greaterThan(0));
      final orders = await db.getOrders();
      expect(orders.length, 1);
      expect(orders.first.items.length, 1);
      expect(orders.first.items.first.quantity, 2);
    });

    test('placeOrder clears the cart', () async {
      final pid = await seedProduct();
      final cartItems = await cartWith(pid);
      await db.placeOrder(
        deliveryAddress: 'Entebbe',
        customerName: 'Bob',
        phoneNumber: '0711111111',
        totalAmount: 5000.0,
        cartItems: cartItems,
      );
      expect(await db.getCartItems(), isEmpty);
    });

    test('placeOrder records totalAmount correctly', () async {
      final pid = await seedProduct(price: 4500.0);
      final cartItems = await cartWith(pid, qty: 3);
      final orderId = await db.placeOrder(
        deliveryAddress: 'Jinja',
        customerName: 'Carol',
        phoneNumber: '0722222222',
        totalAmount: 13500.0,
        cartItems: cartItems,
      );
      final order = (await db.getOrders())
          .firstWhere((o) => o.id == orderId);
      expect(order.totalAmount, 13500.0);
    });

    test('placeOrder status defaults to Pending', () async {
      final pid = await seedProduct();
      final cartItems = await cartWith(pid);
      await db.placeOrder(
        deliveryAddress: 'Mbarara',
        customerName: 'Dan',
        phoneNumber: '0733333333',
        totalAmount: 2500.0,
        cartItems: cartItems,
      );
      final orders = await db.getOrders();
      expect(orders.first.status, 'Pending');
    });

    test('getOrders returns most recent order first', () async {
      for (var i = 0; i < 2; i++) {
        final pid = await seedProduct(name: 'P$i', price: 1000.0);
        final items = await cartWith(pid);
        await db.placeOrder(
          deliveryAddress: 'Addr $i',
          customerName: 'Customer $i',
          phoneNumber: '070000000$i',
          totalAmount: 1000.0,
          cartItems: items,
        );
        // Small delay so order_date strings differ
        await Future.delayed(const Duration(milliseconds: 5));
      }
      final orders = await db.getOrders();
      // DESC order — second inserted should appear first
      expect(orders.first.deliveryAddress, 'Addr 1');
    });

    test('getOrders attaches order_items to each order', () async {
      final pid1 = await seedProduct(name: 'Rice', price: 5500.0);
      final pid2 = await seedProduct(name: 'Sugar', price: 4500.0);
      await db.addToCart(pid1);
      await db.addToCart(pid2);
      final items = await db.getCartItems();
      await db.placeOrder(
        deliveryAddress: 'Kampala',
        customerName: 'Eve',
        phoneNumber: '0744444444',
        totalAmount: 10000.0,
        cartItems: items,
      );
      final orders = await db.getOrders();
      expect(orders.first.items.length, 2);
    });
  });
}