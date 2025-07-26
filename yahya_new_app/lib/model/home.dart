import 'package:yahya_new_app/model/user.dart';

class Home {
  final String name;
  final String email;
  final String profileImagePath;

  Home({
    required this.name,
    required this.email,
    required this.profileImagePath,
  });

  // إنشاء من كائن User
  factory Home.fromUser(User user) {
    return Home(
      name: user.name,
      email: user.email,
      profileImagePath: user.profileImagePath ?? '',
    );
  }
}
