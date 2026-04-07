# EcoMart — Build Plan

**App Name:** EcoMart  
**Platform:** Flutter / Dart  
**Database:** SQLite (`sqflite`)  
**Type:** Class Presentation Project  
**Target Platform:** Android (primary), iOS (secondary)

---

## 🎯 Project Goal

Build a functional supermarket mobile app where customers can browse products, add items to a cart, and place delivery orders — all stored locally using SQLite with no external backend.

---

## 📅 Build Phases

---

### Phase 1 — Project Setup
**Duration:** Day 1

- [ ] Create new Flutter project: `flutter create ecomart`
- [ ] Set up folder structure (`models/`, `screens/`, `widgets/`, `database/`, `providers/`)
- [ ] Add dependencies to `pubspec.yaml`:
  - `sqflite` — local SQLite database
  - `path` — file path helper for SQLite
  - `provider` — state management for cart
- [ ] Add placeholder assets (logo, product images) to `assets/`
- [ ] Configure `pubspec.yaml` assets section
- [ ] Set app name and icon

---

### Phase 2 — Database Layer
**Duration:** Day 1–2

- [ ] Create `db_helper.dart` — singleton database manager
- [ ] Define and create SQLite tables on first launch:
  - `products` (id, name, category, price, image_path, description, stock)
  - `cart_items` (id, product_id, quantity)
  - `orders` (id, delivery_address, total_amount, order_date, status)
  - `order_items` (id, order_id, product_id, quantity, price_at_purchase)
- [ ] Write CRUD methods:
  - `insertProduct()`, `getAllProducts()`, `getProductsByCategory()`
  - `addToCart()`, `getCartItems()`, `updateCartItem()`, `clearCart()`
  - `placeOrder()`, `getOrders()`
- [ ] Seed the database with sample products on first run (at least 15–20 items across 4+ categories)

---

### Phase 3 — Data Models
**Duration:** Day 2

- [ ] `product.dart` — Product model with `fromMap()` / `toMap()`
- [ ] `cart_item.dart` — CartItem model
- [ ] `order.dart` — Order model
- [ ] `order_item.dart` — OrderItem model (line items per order)

---

### Phase 4 — State Management
**Duration:** Day 2

- [ ] Create `cart_provider.dart` using `ChangeNotifier`
- [ ] Implement cart state:
  - List of cart items
  - Total price calculation
  - Add / remove / update quantity methods
  - Clear cart after order placement
- [ ] Wrap app root with `ChangeNotifierProvider`

---

### Phase 5 — UI Screens
**Duration:** Day 3–5

#### 5.1 — Home Screen (`home_screen.dart`)
- [ ] App bar with EcoMart logo and cart icon badge
- [ ] Category chips / horizontal scroll (Fruits, Vegetables, Dairy, Drinks, Snacks, etc.)
- [ ] Featured products grid
- [ ] Search bar (filters product list)

#### 5.2 — Products Screen (`products_screen.dart`)
- [ ] Grid view of products filtered by category
- [ ] `ProductCard` widget: image, name, price, "Add to Cart" button
- [ ] Quantity selector on each card

#### 5.3 — Cart Screen (`cart_screen.dart`)
- [ ] List of cart items with product name, qty, subtotal
- [ ] Increase / decrease / remove item controls
- [ ] Order total summary
- [ ] "Proceed to Checkout" button

#### 5.4 — Checkout Screen (`checkout_screen.dart`)
- [ ] Delivery address text field
- [ ] Customer name field
- [ ] Phone number field
- [ ] Order summary (read-only)
- [ ] "Place Order" button → saves order to SQLite, clears cart, shows confirmation

#### 5.5 — Orders Screen (`orders_screen.dart`)
- [ ] List of past orders from SQLite
- [ ] Each order shows: date, total, status, delivery address
- [ ] Expandable order items per order

---

### Phase 6 — Navigation
**Duration:** Day 5

- [ ] Bottom Navigation Bar with tabs:
  - 🏠 Home
  - 🛍️ Products
  - 🛒 Cart (with badge showing item count)
  - 📦 Orders
- [ ] Route-based navigation for Checkout screen (pushed from Cart)

---

### Phase 7 — Polish & UI Refinement
**Duration:** Day 6

- [ ] Consistent color theme (green/white for eco feel)
- [ ] App-wide `ThemeData` in `main.dart`
- [ ] Loading indicators while DB queries run
- [ ] Empty state widgets (empty cart, no orders yet)
- [ ] Snackbar confirmations ("Item added to cart", "Order placed!")
- [ ] Responsive layout adjustments

---

### Phase 8 — Testing & Demo Prep
**Duration:** Day 7

- [ ] Test all CRUD flows on a physical device or emulator
- [ ] Verify cart updates reflect in real time via Provider
- [ ] Verify orders save correctly and persist after app restart
- [ ] Take screenshots for README (Home, Products, Cart screens)
- [ ] Prepare 3–5 minute demo walkthrough script for class presentation
- [ ] Final `flutter build apk` for demo device

---

## 📦 Deliverables Checklist

- [ ] Working APK / runnable Flutter project
- [ ] `README.md` with screenshots and setup instructions
- [ ] `buildplan.md` (this file)
- [ ] Source code pushed to GitHub (or zipped for submission)
- [ ] Seeded database with realistic product data
- [ ] Live demo on device or emulator

---

## 🗄️ SQLite Tables Summary

| Table | Purpose |
|---|---|
| `products` | All supermarket items for sale |
| `cart_items` | Current items in the customer's cart |
| `orders` | Placed delivery orders |
| `order_items` | Individual line items per order |

---

## 🧱 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0       # SQLite database
  path: ^1.9.0          # Path helper for DB file location
  provider: ^6.1.2      # State management for cart
```

---

## 🗓️ Timeline Overview

| Day | Focus |
|---|---|
| Day 1 | Project setup + DB layer |
| Day 2 | Models + Provider/cart state |
| Day 3–4 | Home, Products, Cart screens |
| Day 5 | Checkout, Orders, Navigation |
| Day 6 | UI polish + theming |
| Day 7 | Testing + screenshots + demo prep |

---

## 📝 Notes

- No internet connection required — all data is local SQLite
- SQLite DB is seeded automatically on first app launch
- Provider is used only for cart state; all other data is fetched directly from SQLite
- Keep product images as local assets for offline reliability
