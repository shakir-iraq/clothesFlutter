class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int categoryId;
  final String? categoryName;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
    this.categoryName,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'imageUrl': imageUrl,
    };
  }

  /// ✅ رابط الصورة الكامل (تعديل baseUrl حسب الحاجة)
  String get fullImageUrl {
    const baseUrl = "http://192.168.18.3:7045/";
    if (imageUrl == null || imageUrl!.isEmpty) return "";
    return imageUrl!.startsWith("http") ? imageUrl! : baseUrl + imageUrl!;
  }
}
