import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit-state/category-Cub-State/category-cub.dart';
import '../cubit-state/category-Cub-State/category-state.dart';
import '../model/category.dart';
import '../Controlls/apiCategory.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  void _showAddCategoryModal(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "إضافة تصنيف جديد",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'اسم التصنيف',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final category = Categorys(
                      name: controller.text.trim(),
                    ); // ** بدون id **
                    context
                        .read<CategoryCubit>()
                        .createCategoryFromFront(category);
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('حفظ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 240, 243, 245),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryCubit(ApiCategory())..getCategoriesToFront(),
      child: Scaffold(
        backgroundColor: const Color(0xFF232F34),
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, // ← هنا تغيّر لون أيقونة الهامبرغر
          ),
          actions: [
            FloatingActionButton(
              onPressed: () => _showAddCategoryModal(context),
              backgroundColor: Color.fromARGB(255, 44, 60, 71),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ],
          title: const Text(
            'إدارة التصنيفات',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF232F34),
        ),
        body: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoryError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is CategoryLoaded) {
              final categories = state.categories;
              if (categories.isEmpty) {
                return const Center(child: Text('لا توجد تصنيفات بعد'));
              }
              return Directionality(
                textDirection: TextDirection.rtl,
                child: ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      leading: const Icon(Icons.category,
                          color: Color.fromARGB(255, 178, 178, 215)),
                      title: Text(
                        category.name,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 235, 101, 91),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: AlertDialog(
                                title: const Text("تأكيد الحذف"),
                                content: const Text(
                                    "هل أنت متأكد أنك تريد حذف هذا  التصنيف"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("إلغاء"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("حذف",
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ),
                          );

                          if (confirm == true) {
                            context
                                .read<CategoryCubit>()
                                .deleteCategory(category.id!);
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
