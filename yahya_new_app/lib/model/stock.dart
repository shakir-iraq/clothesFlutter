class Stock {
  final int id;
  final int inventoryId;
  final int quantity;
  final String? notes;
  final DateTime? movementDate;

  // للعرض
  final int? productId;
  final String? productName;

  Stock({
    required this.id,
    required this.inventoryId,
    required this.quantity,
    this.notes,
    this.movementDate,
    this.productId,
    this.productName,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      inventoryId: json['inventoryId'],
      quantity: json['quantity'],
      notes: json['notes'],
      movementDate: json['movementDate'] != null
          ? DateTime.parse(json['movementDate'])
          : null,
      productId: json['productId'],
      productName: json['productName'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'inventoryId': inventoryId,
      'quantity': quantity,
      'notes': notes,
    };
  }
}
