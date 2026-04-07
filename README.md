# EcoMart 🛒

<p align="center">
  <!-- LOGO PLACEHOLDER -->
  <img src="assets/images/logo.png" alt="EcoMart Logo" width="160" height="160"/>
  <!-- Replace the above with your actual logo file path -->
</p>

<h3 align="center">Your Smart Supermarket, Delivered to Your Door</h3>

<p align="center">
  A Flutter-powered supermarket shopping app built for convenience —
  browse products, add to cart, and get them delivered right to you.
</p>

---

## 📸 Screenshots

<p align="center">
  <img src="assets/screenshots/screenshot_home.png" alt="Home Screen" width="220"/>
  &nbsp;&nbsp;&nbsp;
  <img src="assets/screenshots/screenshot_products.png" alt="Products Screen" width="220"/>
  &nbsp;&nbsp;&nbsp;
  <img src="assets/screenshots/screenshot_cart.png" alt="Cart & Checkout" width="220"/>
</p>

<!-- 
  SCREENSHOT PLACEHOLDERS:
  - screenshot_home.png     → Home / landing screen showing featured products & categories
  - screenshot_products.png → Product listing / browsing screen
  - screenshot_cart.png     → Shopping cart and checkout / delivery form screen
  Replace these paths with your actual screenshot files before presenting.
-->

---

## 🌿 About EcoMart

EcoMart is a Flutter/Dart supermarket application developed as a class project. It simulates a real-world grocery shopping experience where customers can:

- Browse product categories and listings
- Add items to a cart and manage quantities
- Place orders for home delivery
- View order history and track past purchases

All data is stored **locally using SQLite** (via the `sqflite` package) — no external database or internet connection required. Perfect for offline demos and class presentations.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🏠 Home Screen | Featured products, categories, and promotions |
| 🛍️ Product Browsing | Browse items by category with search support |
| 🛒 Shopping Cart | Add, remove, and update item quantities |
| 🚚 Home Delivery | Enter delivery address and place orders |
| 📦 Order History | View past orders stored locally |
| 💾 Local Database | SQLite via `sqflite` — no backend needed |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart |
| Local Database | SQLite (`sqflite` package) |
| State Management | Provider / setState |
| Navigation | Flutter Navigator 2.0 |

---

## 🗂️ Project Structure

```
ecomart/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── product.dart
│   │   ├── cart_item.dart
│   │   └── order.dart
│   ├── database/
│   │   └── db_helper.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── products_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── checkout_screen.dart
│   │   └── orders_screen.dart
│   ├── widgets/
│   │   ├── product_card.dart
│   │   └── cart_badge.dart
│   └── providers/
│       └── cart_provider.dart
├── assets/
│   ├── images/
│   └── screenshots/
├── pubspec.yaml
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter plugin

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/ecomart.git

# 2. Navigate into the project
cd ecomart

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

### Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.9.0
  provider: ^6.1.2
```

---

## 🗄️ Database Schema

EcoMart uses SQLite with the following tables:

**`products`**
```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  category TEXT,
  price REAL NOT NULL,
  image_path TEXT,
  description TEXT,
  stock INTEGER DEFAULT 0
);
```

**`cart_items`**
```sql
CREATE TABLE cart_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER,
  quantity INTEGER NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(id)
);
```

**`orders`**
```sql
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  delivery_address TEXT NOT NULL,
  total_amount REAL NOT NULL,
  order_date TEXT NOT NULL,
  status TEXT DEFAULT 'Pending'
);
```

---

## 👩‍💻 Author

> Built for class presentation purposes.
> Replace this section with your name, student ID, and course.

---

## 📄 License

This project is for educational use only.
