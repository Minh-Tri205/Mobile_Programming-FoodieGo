// lib/core/models/food_model.dart

class FoodModel {
  final int foodId;
  final int? categoryId;
  final String categoryName; // để hiển thị UI, không cần join SQL
  final String name;
  final double price;
  final String? imageUrl;
  final String? description;
  final int totalSold;
  final bool isActive;

  const FoodModel({
    required this.foodId,
    this.categoryId,
    this.categoryName = '',
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
    this.totalSold = 0,
    this.isActive = true,
  });

  // Dữ liệu mẫu khớp với INSERT trong SQL:
  // Món Nước | Cơm Văn Phòng | Đồ Uống
  static List<FoodModel> sampleFoods = const [
    FoodModel(
      foodId: 1,
      categoryId: 1,
      categoryName: 'Món Nước',
      name: 'Phở Bò Đặc Biệt',
      price: 50000,
      imageUrl: 'assets/images/pho_bo.jpg',
      description: 'Phở bò với nước dùng đậm đà, thịt bò tươi mềm.',
      totalSold: 120,
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
    ),
  ];
}