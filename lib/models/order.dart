import 'order_item.dart';

class Order {
  final int? id;
  final String deliveryAddress;
  final String customerName;
  final String phoneNumber;
  final double totalAmount;
  final String orderDate;
  final String status;
  List<OrderItem> items;

  Order({
    this.id,
    required this.deliveryAddress,
    required this.customerName,
    required this.phoneNumber,
    required this.totalAmount,
    required this.orderDate,
    this.status = 'Pending',
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'delivery_address': deliveryAddress,
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'total_amount': totalAmount,
      'order_date': orderDate,
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      deliveryAddress: map['delivery_address'] as String,
      customerName: map['customer_name'] as String? ?? '',
      phoneNumber: map['phone_number'] as String? ?? '',
      totalAmount: (map['total_amount'] as num).toDouble(),
      orderDate: map['order_date'] as String,
      status: map['status'] as String? ?? 'Pending',
    );
  }
}
