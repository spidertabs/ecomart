import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final categories = await DBHelper.instance.getCategories();
    final products = await DBHelper.instance.getAllProducts();
    setState(() {
      _categories = ['All', ...categories];
      _products = products;
      _loading = false;
    });
  }

  Future<void> _filter(String category) async {
    setState(() {
      _selectedCategory = category;
      _loading = true;
    });
    final products = category == 'All'
        ? await DBHelper.instance.getAllProducts()
        : await DBHelper.instance.getProductsByCategory(category);
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      await _filter(_selectedCategory);
      return;
    }
    final results = await DBHelper.instance.searchProducts(query);
    setState(() => _products = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search products…',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _categories.length,
              itemBuilder: (ctx, i) => CategoryChip(
                label: _categories[i],
                selected: _categories[i] == _selectedCategory,
                onTap: () => _filter(_categories[i]),
              ),
            ),
          ),

          // Products grid
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.black26),
                            SizedBox(height: 12),
                            Text('No products found',
                                style: TextStyle(color: Colors.black45)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (ctx, i) =>
                            ProductCard(product: _products[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
