class Coolor {
  final int? id; // أصبح اختياري
  final String name;

  Coolor({this.id, required this.name});

  factory Coolor.fromJson(Map<String, dynamic> json) {
    return Coolor(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name, // لا ترسل id عند الإضافة
      };
}
