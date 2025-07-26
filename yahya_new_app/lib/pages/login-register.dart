import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yahya_new_app/cubit-state/user-cubit-state/user-cub.dart';
import 'package:yahya_new_app/cubit-state/user-cubit-state/user-state.dart';
import 'package:yahya_new_app/pages/home.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({Key? key}) : super(key: key);

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  String? imagePath; // للمسار في الأجهزة العادية، أو اسم الصورة في الويب
  Uint8List? webImage; // لرفع صورة من الويب (بايت)
  String? webImageName; // اسم الصورة في الويب

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
      _formKey.currentState?.reset();
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      imagePath = null;
      webImage = null;
      webImageName = null;
    });
  }

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb, // لو ويب نحمل البيانات بدل المسار
    );

    if (result != null) {
      if (kIsWeb) {
        setState(() {
          webImage = result.files.first.bytes;
          webImageName = result.files.first.name; // حفظ اسم الملف في الويب
          imagePath = null; // تأكد أن مسار الجهاز فارغ للويب
        });
      } else {
        setState(() {
          imagePath = result.files.first.path;
          webImage = null;
          webImageName = null;
        });
      }
    }
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    final userCubit = context.read<UserCubit>();

    if (isLogin) {
      userCubit.loginUser(email, password);
    } else {
      userCubit.addUser(
        name: name,
        email: email,
        password: password,
        imageFilePath: imagePath,
        imageBytes: webImage,
        imageFileName: webImageName,
      );
    }
  }

  void _saveUserDataAndNavigate(BuildContext context, UserLoaded state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', state.user.name);
    await prefs.setString('userEmail', state.user.email);
    await prefs.setString('userImagePath', state.user.profileImagePath ?? '');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          name: state.user.name,
          email: state.user.email,
          profileImagePath: state.user.profileImagePath ?? '',
        ),
      ),
    );
  }

  Widget imagePreview() {
    if (kIsWeb && webImage != null) {
      return Image.memory(webImage!, height: 100);
    } else if (imagePath != null) {
      return Image.file(File(imagePath!), height: 100);
    }
    return const Text('لم يتم اختيار صورة');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFF344955);
    final accentColor = const Color(0xFFF9AA33);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            elevation: 15,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 35),
              child: BlocConsumer<UserCubit, UserState>(
                listener: (context, state) {
                  if (state is UserLoaded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              isLogin ? 'تم تسجيل الدخول' : 'تم إنشاء الحساب')),
                    );
                    _saveUserDataAndNavigate(context, state);
                  } else if (state is UserError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                          style: theme.textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!isLogin) ...[
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'الاسم',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'ادخل الاسم'
                                : null,
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: pickImage,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor),
                            child: const Text('اختر صورة'),
                          ),
                          const SizedBox(height: 10),
                          imagePreview(),
                        ],
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || !val.contains('@')
                              ? 'بريد غير صالح'
                              : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'كلمة المرور',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.length < 6
                              ? 'على الأقل 6 حروف'
                              : null,
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            isLogin ? 'دخول' : 'تسجيل',
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: toggleForm,
                          child: Text(
                            isLogin ? 'إنشاء حساب جديد' : 'لديك حساب؟ دخول',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
