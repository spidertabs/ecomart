import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ecomart.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        image_path TEXT,
        description TEXT,
        stock INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        delivery_address TEXT NOT NULL,
        customer_name TEXT,
        phone_number TEXT,
        total_amount REAL NOT NULL,
        order_date TEXT NOT NULL,
        status TEXT DEFAULT 'Pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price_at_purchase REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id)
      )
    ''');

    await _seedProducts(db);
  }

  // ─── SEEDING ────────────────────────────────────────────────────────────────

  Future<void> _seedProducts(Database db) async {
    final products = [
      // Fruits
      {'name': 'Banana', 'category': 'Fruits', 'price': 2500.0, 'image_path': 'assets/images/banana.png', 'description': 'Fresh ripe bananas, sold per bunch.', 'stock': 50},
      {'name': 'Mango', 'category': 'Fruits', 'price': 3500.0, 'image_path': 'assets/images/mango.png', 'description': 'Sweet Ugandan mangoes.', 'stock': 40},
      {'name': 'Avocado', 'category': 'Fruits', 'price': 1500.0, 'image_path': 'assets/images/avocado.png', 'description': 'Creamy ripe avocados.', 'stock': 30},
      {'name': 'Pineapple', 'category': 'Fruits', 'price': 4000.0, 'image_path': 'assets/images/pineapple.png', 'description': 'Juicy fresh pineapple.', 'stock': 20},
      // Vegetables
      {'name': 'Tomatoes (kg)', 'category': 'Vegetables', 'price': 3000.0, 'image_path': 'assets/images/tomatoes.png', 'description': 'Fresh market tomatoes per kg.', 'stock': 60},
      {'name': 'Onions (kg)', 'category': 'Vegetables', 'price': 2000.0, 'image_path': 'assets/images/onions.png', 'description': 'Red onions per kg.', 'stock': 80},
      {'name': 'Sukuma Wiki', 'category': 'Vegetables', 'price': 1000.0, 'image_path': 'assets/images/sukuma.png', 'description': 'Fresh kale leaves, per bunch.', 'stock': 45},
      {'name': 'Carrots (kg)', 'category': 'Vegetables', 'price': 2500.0, 'image_path': 'assets/images/carrots.png', 'description': 'Crunchy carrots per kg.', 'stock': 35},
      // Dairy
      {'name': 'Fresh Milk (1L)', 'category': 'Dairy', 'price': 4500.0, 'image_path': 'assets/images/milk.png', 'description': 'Full cream fresh milk, 1 litre.', 'stock': 100},
      {'name': 'Yoghurt (500ml)', 'category': 'Dairy', 'price': 5000.0, 'image_path': 'assets/images/yoghurt.png', 'description': 'Strawberry flavoured yoghurt.', 'stock': 50},
      {'name': 'Eggs (tray)', 'category': 'Dairy', 'price': 14000.0, 'image_path': 'assets/images/eggs.png', 'description': 'Farm-fresh eggs, 30 pcs per tray.', 'stock': 30},
      // Drinks
      {'name': 'Water (500ml)', 'category': 'Drinks', 'price': 1000.0, 'image_path': 'assets/images/water.png', 'description': 'Pure mineral water, 500ml bottle.', 'stock': 200},
      {'name': 'Soda (500ml)', 'category': 'Drinks', 'price': 2000.0, 'image_path': 'assets/images/soda.png', 'description': 'Assorted sodas – Coke, Fanta, Sprite.', 'stock': 120},
      {'name': 'Juice (1L)', 'category': 'Drinks', 'price': 6000.0, 'image_path': 'assets/images/juice.png', 'description': 'Tropical fruit juice, 1 litre.', 'stock': 60},
      // Snacks
      {'name': 'Crisps (100g)', 'category': 'Snacks', 'price': 2500.0, 'image_path': 'assets/images/crisps.png', 'description': 'Salted potato crisps.', 'stock': 90},
      {'name': 'Biscuits (pkt)', 'category': 'Snacks', 'price': 3000.0, 'image_path': 'assets/images/biscuits.png', 'description': 'Assorted cream biscuits.', 'stock': 70},
      // Staples
      {'name': 'Rice (1kg)', 'category': 'Staples', 'price': 5500.0, 'image_path': 'assets/images/rice.png', 'description': 'Long grain white rice, 1 kg.', 'stock': 80},
      {'name': 'Posho / Maize Flour (2kg)', 'category': 'Staples', 'price': 7000.0, 'image_path': 'assets/images/posho.png', 'description': 'Golden maize flour, 2 kg pack.', 'stock': 60},
      {'name': 'Cooking Oil (1L)', 'category': 'Staples', 'price': 9000.0, 'image_path': 'assets/images/oil.png', 'description': 'Refined sunflower cooking oil, 1 litre.', 'stock': 50},
      {'name': 'Sugar (1kg)', 'category': 'Staples', 'price': 4500.0, 'image_path': 'assets/images/sugar.png', 'description': 'White granulated sugar, 1 kg.', 'stock': 75},
    ];

    final batch = db.batch();
    for (final p in products) {
      batch.insert('products', p);
    }
    await batch.commit(noResult: true);
  }

  // ─── PRODUCTS ───────────────────────────────────────────────────────────────

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
    );
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT DISTINCT category FROM products ORDER BY category');
    return result.map((r) => r['category'] as String).toList();
  }

  // ─── CART ────────────────────────────────────────────────────────────────────

  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT c.id, c.product_id, c.quantity,
             p.name, p.category, p.price, p.image_path, p.description, p.stock
      FROM cart_items c
      JOIN products p ON c.product_id = p.id
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
    final db = await database;
    final existing = await db.query(
      'cart_items',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    if (existing.isEmpty) {
      await db.insert('cart_items', {'product_id': productId, 'quantity': 1});
    } else {
      final current = existing.first['quantity'] as int;
      await db.update(
        'cart_items',
        {'quantity': current + 1},
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    }
  }

  Future<void> updateCartItemQty(int cartItemId, int quantity) async {
    final db = await database;
    if (quantity <= 0) {
      await db.delete('cart_items', where: 'id = ?', whereArgs: [cartItemId]);
    } else {
      await db.update(
        'cart_items',
        {'quantity': quantity},
        where: 'id = ?',
        whereArgs: [cartItemId],
      );
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    final db = await database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [cartItemId]);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  // ─── ORDERS ─────────────────────────────────────────────────────────────────

  Future<int> placeOrder({
    required String deliveryAddress,
    required String customerName,
    required String phoneNumber,
    required double totalAmount,
    required List<CartItem> cartItems,
  }) async {
    final db = await database;
    final orderId = await db.insert('orders', {
      'delivery_address': deliveryAddress,
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'total_amount': totalAmount,
      'order_date': DateTime.now().toIso8601String(),
      'status': 'Pending',
    });

    final batch = db.batch();
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
    final db = await database;
    final orderMaps =
        await db.query('orders', orderBy: 'order_date DESC');
    final orders = orderMaps.map((m) => Order.fromMap(m)).toList();

    for (final order in orders) {
      final itemMaps = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [order.id],
      );
      order.items = itemMaps.map((m) => OrderItem.fromMap(m)).toList();
    }
    return orders;
  }
}
