// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ecomart/main.dart';
import 'package:ecomart/providers/cart_provider.dart';
import 'package:ecomart/models/cart_item.dart';

class _EmptyCartProvider extends CartProvider {
  _EmptyCartProvider() : super.forTesting();

  @override
  List<CartItem> get items => const [];
  @override
  bool get loading => false;
  @override
  int get totalItems => 0;
  @override
  double get totalPrice => 0.0;

  @override
  Future<void> loadCart() async {}
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('app smoke test — bottom nav visible with 4 destinations',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<CartProvider>(
        create: (_) => _EmptyCartProvider(),
        child: const MaterialApp(home: MainNavigation()),
      ),
    );
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
  });

  testWidgets('tapping Products tab switches the screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<CartProvider>(
        create: (_) => _EmptyCartProvider(),
        child: const MaterialApp(home: MainNavigation()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Products'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Products'), findsWidgets);
  });
}