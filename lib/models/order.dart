class Order {
  final String id;
  final bool isActive;
  final double price;
  final String company;
  final String picture;
  final String buyer;
  final List<String> tags;
  final String status;
  final DateTime registered; // Add this field

  Order({
    required this.id,
    required this.isActive,
    required this.price,
    required this.company,
    required this.picture,
    required this.buyer,
    required this.tags,
    required this.status,
    required this.registered, // Initialize it here
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      isActive: json['isActive'] as bool,
      price: double.parse(
          (json['price'] as String).replaceAll('\$', '').replaceAll(',', '')),
      company: json['company'] as String,
      picture: json['picture'] as String,
      buyer: json['buyer'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
      status: json['status'] as String,
      registered: DateTime.parse(json['registered']), // Parse the date
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isActive': isActive,
      'price': price,
      'company': company,
      'picture': picture,
      'buyer': buyer,
      'tags': tags,
      'status': status,
      'registered': registered.toIso8601String(), // Convert date to string
    };
  }

  double get totalPrice => price;
}
