class RestaurantModel {
  final String id;
  final String name;
  final String emoji;
  final double rating;
  final int deliveryMinutes;
  final String deliveryFee;
  final List<String> tags;
  final String cuisine;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.rating,
    required this.deliveryMinutes,
    required this.deliveryFee,
    required this.tags,
    required this.cuisine,
  });

  static List<RestaurantModel> sampleRestaurants = [
    const RestaurantModel(
      id: '1',
      name: 'Phở 24 - Chi nhánh Q1',
      emoji: '🍜',
      rating: 4.9,
      deliveryMinutes: 30,
      deliveryFee: 'Miễn phí',
      tags: ['Việt Nam', 'Đặc sản', '🔥 Hot'],
      cuisine: 'Việt Nam',
    ),
    const RestaurantModel(
      id: '2',
      name: 'Sakura Sushi Bar',
      emoji: '🍣',
      rating: 4.8,
      deliveryMinutes: 35,
      deliveryFee: '15.000đ',
      tags: ['Nhật Bản', 'Premium'],
      cuisine: 'Nhật Bản',
    ),
    const RestaurantModel(
      id: '3',
      name: "Domino's Pizza",
      emoji: '🍕',
      rating: 4.6,
      deliveryMinutes: 25,
      deliveryFee: 'Miễn phí',
      tags: ['Ý', 'Fast food'],
      cuisine: 'Ý',
    ),
    const RestaurantModel(
      id: '4',
      name: 'KFC Gà Rán',
      emoji: '🍗',
      rating: 4.5,
      deliveryMinutes: 20,
      deliveryFee: '10.000đ',
      tags: ['Mỹ', 'Fast food'],
      cuisine: 'Fast food',
    ),
  ];
}
