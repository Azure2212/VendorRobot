class Product {
  final int id;
  final String name;
  final String imagePath;
  double price;

  Product({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      imagePath: json['imagePath'],
      price: json['price'],
    );
  }
}