import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yahya_new_app/cubit-state/user-cubit-state/user-cub.dart';
import 'package:yahya_new_app/pages/home.dart';
import 'package:yahya_new_app/pages/login-register.dart';
import 'package:yahya_new_app/Controlls/apiUser.dart';
import 'package:yahya_new_app/pages/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final name = prefs.getString('userName') ?? '';
  final email = prefs.getString('userEmail') ?? '';
  final profileImagePath = prefs.getString('userImagePath') ?? '';

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    name: name,
    email: email,
    profileImagePath: profileImagePath,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String name;
  final String email;
  final String profileImagePath;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.name,
    required this.email,
    required this.profileImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserCubit(ApiUser()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Yahya Flutter App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: isLoggedIn
            ? HomePage(
                name: name,
                email: email,
                profileImagePath: profileImagePath,
              )
            : const LoginRegisterPage(),
      ),
    );
  }
}
