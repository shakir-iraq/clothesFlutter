class Inventory {
  final int id;
  final int productId;
  final String productName;
  final String? imageUrl;
  final int coolorId;
  final String colorName;
  final int siizeId;
  final String sizeName;
  final int quantity;

  Inventory({
    required this.id,
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.coolorId,
    required this.colorName,
    required this.siizeId,
    required this.sizeName,
    required this.quantity,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'] ?? '',
      imageUrl: json['productImageUrl'],
      coolorId: json['coolorId'],
      colorName: json['coolorName'] ?? '',
      siizeId: json['siizeId'],
      sizeName: json['siizeName'] ?? '',
      quantity: json['quantity'],
    );
  }

  String get fullImageUrl {
    const baseUrl = "http://192.168.18.3:7045/";
    if (imageUrl == null || imageUrl!.isEmpty) return "";
    return imageUrl!.startsWith("http") ? imageUrl! : baseUrl + imageUrl!;
  }
}
