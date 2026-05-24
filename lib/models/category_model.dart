class CategoryModel {
  final int categoryId;
  final String name;
  final String? imageUrl;
  final bool? isActive;

  CategoryModel({
    required this.categoryId,
    required this.name,
    this.imageUrl,
    this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['categoryId'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}
