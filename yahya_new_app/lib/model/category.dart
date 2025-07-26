class Categorys {
  final int? id; // أصبح اختياري
  final String name;

  Categorys({this.id, required this.name});

  factory Categorys.fromJson(Map<String, dynamic> json) {
    return Categorys(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name, // لا ترسل id عند الإضافة
      };
}
