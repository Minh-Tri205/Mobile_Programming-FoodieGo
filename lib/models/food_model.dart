// lib/models/food_model.dart
// Khớp bảng food_items trong Database_Food_App.sql
class FoodModel {
  final int? foodId;
  final int? categoryId;
  final String categoryName; // hiển thị UI (JOIN từ categories)
  final String name;
  final double price;
  final String? imageUrl;
  final String? description;
  final int totalSold;
  final int stockQuantity;
  final double avgRating;
  final bool isActive;
  final DateTime? deletedAt;

  const FoodModel({
    this.foodId,
    this.categoryId,
    this.categoryName = '',
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
    this.totalSold = 0,
    this.stockQuantity = 0,
    this.avgRating = 0,
    this.isActive = true,
    this.deletedAt,
  });

  bool get inStock => stockQuantity > 0;

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    // Backend EF có thể trả category nested qua .Include(Category)
    final cat = json['category'] as Map<String, dynamic>?;

    // Chấp nhận bool, int (0/1), hoặc null (default true)
    bool parseActive(dynamic v) {
      if (v == null) return true;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      return true;
    }

    return FoodModel(
      foodId: json['foodId'],
      categoryId: json['categoryId'] ?? cat?['categoryId'],
      categoryName:
          json['categoryName'] ?? cat?['name'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      description: json['description'],
      totalSold: json['totalSold'] ?? 0,
      stockQuantity: json['stockQuantity'] ?? 0,
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      isActive: parseActive(json['isActive']),
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'foodId': foodId,
    'categoryId': categoryId,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'description': description,
    'totalSold': totalSold,
    'stockQuantity': stockQuantity,
    'avgRating': avgRating,
    'isActive': isActive,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  // Dữ liệu mẫu — fallback khi chưa nối backend
  static const List<FoodModel> sampleFoods = [
    FoodModel(
      foodId: 1,
      categoryId: 1,
      categoryName: 'Món Nước',
      name: 'Phở Bò Đặc Biệt',
      price: 50000,
      imageUrl: 'assets/images/pho_bo.jpg',
      description: 'Phở bò với nước dùng đậm đà, thịt bò tươi mềm.',
      totalSold: 120,
      stockQuantity: 50,
      avgRating: 4.8,
    ),
    FoodModel(
      foodId: 2,
      categoryId: 1,
      categoryName: 'Món Nước',
      name: 'Bún Bò Huế',
      price: 45000,
      imageUrl: 'assets/images/bun_bo.jpg',
      description: 'Bún bò Huế cay nồng, nước dùng đặc trưng miền Trung.',
      totalSold: 95,
      stockQuantity: 45,
      avgRating: 4.7,
    ),
    FoodModel(
      foodId: 3,
      categoryId: 2,
      categoryName: 'Cơm Văn Phòng',
      name: 'Cơm Sườn Nướng',
      price: 45000,
      imageUrl: 'assets/images/com_suon.jpg',
      description: 'Cơm trắng dẻo với sườn nướng thơm lừng, kèm rau củ.',
      totalSold: 80,
      stockQuantity: 40,
      avgRating: 4.6,
    ),
    FoodModel(
      foodId: 4,
      categoryId: 2,
      categoryName: 'Cơm Văn Phòng',
      name: 'Cơm Gà Xối Mỡ',
      price: 40000,
      imageUrl: 'assets/images/com_ga.jpg',
      description: 'Cơm gà xối mỡ giòn rụm, nước chấm đặc biệt.',
      totalSold: 60,
      stockQuantity: 50,
      avgRating: 4.5,
    ),
    FoodModel(
      foodId: 5,
      categoryId: 3,
      categoryName: 'Đồ Uống',
      name: 'Trà Đào Cam Sả',
      price: 25000,
      imageUrl: 'assets/images/tra_dao.jpg',
      description: 'Trà đào thơm mát kết hợp cam và sả tươi.',
      totalSold: 200,
      stockQuantity: 100,
      avgRating: 4.7,
    ),
    FoodModel(
      foodId: 6,
      categoryId: 3,
      categoryName: 'Đồ Uống',
      name: 'Cà Phê Sữa Đá',
      price: 20000,
      imageUrl: 'assets/images/ca_phe.jpg',
      description: 'Cà phê Việt Nam pha phin truyền thống với sữa đặc.',
      totalSold: 150,
      stockQuantity: 150,
      avgRating: 4.7,
    ),
  ];

  FoodModel copyWith({
    int? foodId,
    int? categoryId,
    String? categoryName,
    String? name,
    double? price,
    String? imageUrl,
    String? description,
    int? totalSold,
    int? stockQuantity,
    double? avgRating,
    bool? isActive,
    DateTime? deletedAt,
  }) {
    return FoodModel(
      foodId: foodId ?? this.foodId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      totalSold: totalSold ?? this.totalSold,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      avgRating: avgRating ?? this.avgRating,
      isActive: isActive ?? this.isActive,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
