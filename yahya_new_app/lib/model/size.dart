class Siize {
  final int? id; // أصبح اختياري
  final String name;

  Siize({this.id, required this.name});

  factory Siize.fromJson(Map<String, dynamic> json) {
    return Siize(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name, // لا ترسل id عند الإضافة
      };
}
