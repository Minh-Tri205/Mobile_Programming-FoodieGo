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
      title: 'Food App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const FoodListScreen(),
    );
  }
}

class FoodModel {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviewCount;
  final String category;
  final String description;
  final int calories;
  final int deliveryMinutes;
  final String restaurantName;

  const FoodModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.description,
    required this.calories,
    required this.deliveryMinutes,
    required this.restaurantName,
  });

  static List<FoodModel> sampleFoods = [
    const FoodModel(
      id: '1',
      name: 'Bún Bò Huế Đặc Biệt',
      imageUrl: 'assets/images/bun_bo_hue.jpg',
      price: 45000,
      rating: 4.8,
      reviewCount: 238,
      category: 'Việt Nam',
      description: 'Bún bò Huế với nước dùng đậm đà...',
      calories: 450,
      deliveryMinutes: 25,
      restaurantName: 'Phở 24',
    ),
    const FoodModel(
      id: '2',
      name: 'Pizza Hải Sản',
      imageUrl: 'assets/images/pizza_hai_san.jpg',
      price: 89000,
      rating: 4.6,
      reviewCount: 156,
      category: 'Ý',
      description: 'Pizza hải sản với đế giòn...',
      calories: 620,
      deliveryMinutes: 30,
      restaurantName: 'Domino\'s Pizza',
    ),
    const FoodModel(
      id: '3',
      name: 'Sushi Cuộn Thập Cẩm',
      imageUrl: 'assets/images/sushi_combo.jpg',
      price: 120000,
      rating: 4.9,
      reviewCount: 312,
      category: 'Nhật Bản',
      description: 'Sushi cuộn đặc biệt...',
      calories: 380,
      deliveryMinutes: 35,
      restaurantName: 'Sakura Sushi',
    ),
    const FoodModel(
      id: '4',
      name: 'Burger Bò Phô Mai',
      imageUrl: 'assets/images/burger_cheese.jpg',
      price: 65000,
      rating: 4.7,
      reviewCount: 198,
      category: 'Fast food',
      description: 'Burger bò Mỹ...',
      calories: 580,
      deliveryMinutes: 20,
      restaurantName: 'Burger King',
    ),
  ];
}

// ================= SCREEN =================
class FoodListScreen extends StatelessWidget {
  const FoodListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final foods = FoodModel.sampleFoods;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍽️ Danh sách món ăn'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: FoodItem(food: food),
          );
        },
      ),
    );
  }
}

// ================= ITEM UI =================
class FoodItem extends StatelessWidget {
  final FoodModel food;

  const FoodItem({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: Image.asset(
              food.imageUrl,
              width: 100,
              height: 100,
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
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    food.restaurantName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text('${food.rating}'),
                      const SizedBox(width: 8),
                      Text('(${food.reviewCount})'),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Text(
                        '${food.price.toInt()}đ',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text('${food.deliveryMinutes} phút'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}