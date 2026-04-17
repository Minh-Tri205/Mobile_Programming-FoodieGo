import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Order App',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const OrderScreen(),
    );
  }
}

// ================= MODEL (GIỮ NGUYÊN) =================
enum OrderStatus { delivering, preparing, delivered, cancelled }

class OrderModel {
  final String id;
  final String restaurantName;
  final String restaurantEmoji;
  final String itemsSummary;
  final double total;
  final OrderStatus status;
  final String timeLabel;

  const OrderModel({
    required this.id,
    required this.restaurantName,
    required this.restaurantEmoji,
    required this.itemsSummary,
    required this.total,
    required this.status,
    required this.timeLabel,
  });

  static List<OrderModel> sampleOrders = [
    const OrderModel(
      id: '#DH240401',
      restaurantName: 'Phở 24 - Quận 1',
      restaurantEmoji: '🍜',
      itemsSummary: 'Bún Bò Huế x2, Pizza x1',
      total: 174000,
      status: OrderStatus.delivering,
      timeLabel: 'Hôm nay 09:41',
    ),
    const OrderModel(
      id: '#DH240401B',
      restaurantName: "Domino's Pizza",
      restaurantEmoji: '🍕',
      itemsSummary: 'Pizza Hải Sản x1',
      total: 89000,
      status: OrderStatus.preparing,
      timeLabel: 'Hôm nay 08:20',
    ),
    const OrderModel(
      id: '#DH240330',
      restaurantName: 'Sakura Sushi Bar',
      restaurantEmoji: '🍣',
      itemsSummary: 'Sushi cuộn x2, Ramen x1',
      total: 245000,
      status: OrderStatus.delivered,
      timeLabel: 'Hôm qua 19:30',
    ),
    const OrderModel(
      id: '#DH240328',
      restaurantName: 'Burger King',
      restaurantEmoji: '🍔',
      itemsSummary: 'Burger Bò x1, Khoai tây x1',
      total: 95000,
      status: OrderStatus.cancelled,
      timeLabel: '03/04 12:00',
    ),
  ];
}

// ================= IMAGE MAP (KHÔNG DÙNG EMOJI TRONG UI) =================
String getRestaurantImage(String name) {
  if (name.contains('Phở 24')) {
    return 'assets/images/bun_bo_hue.jpg';
  } else if (name.contains('Domino')) {
    return 'assets/images/pizza.jpg';
  } else if (name.contains('Sakura')) {
    return 'assets/images/sushi.jpg';
  } else if (name.contains('Burger King')) {
    return 'assets/images/burger.jpg';
  }
  return 'assets/images/default_food.jpg';
}

// ================= UI =================
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = OrderModel.sampleOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng của bạn'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Row(
              children: [
                // IMAGE (THAY ICON)
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  child: Image.asset(
                    getRestaurantImage(order.restaurantName),
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),

                // INFO
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TÊN NHÀ HÀNG (THAY ICON)
                        Text(
                          order.restaurantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(order.itemsSummary),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Text(
                              '${order.total.toInt()}đ',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(order.timeLabel),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          getStatusText(order.status),
                          style: TextStyle(
                            color: getStatusColor(order.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ================= STATUS =================
String getStatusText(OrderStatus status) {
  switch (status) {
    case OrderStatus.delivering:
      return 'Đang giao';
    case OrderStatus.preparing:
      return 'Đang chuẩn bị';
    case OrderStatus.delivered:
      return 'Đã giao';
    case OrderStatus.cancelled:
      return 'Đã huỷ';
  }
}

Color getStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.delivering:
      return Colors.orange;
    case OrderStatus.preparing:
      return Colors.blue;
    case OrderStatus.delivered:
      return Colors.green;
    case OrderStatus.cancelled:
      return Colors.red;
  }
}