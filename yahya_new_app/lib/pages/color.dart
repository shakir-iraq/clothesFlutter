import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahya_new_app/Controlls/apiCoolor.dart';
import 'package:yahya_new_app/Controlls/apiSiize.dart';
import 'package:yahya_new_app/cubit-state/color-Cub-State%20copy/coolor-cub.dart';
import 'package:yahya_new_app/cubit-state/color-Cub-State%20copy/coolor-state.dart';
import 'package:yahya_new_app/cubit-state/size-Cub-State/siize-cub.dart';
import 'package:yahya_new_app/model/Coolor.dart';

class ColorListPage extends StatelessWidget {
  const ColorListPage({super.key});

  void _showAddColorModal(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
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
                  "إضافة لون جديد",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'اسم اللون',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final color = Coolor(
                        name: controller.text.trim(),
                      );
                      context.read<CoolorCubit>().createcoolorFromFront(color);
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 228, 230, 241),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoolorCubit(ApiCoolor())..getcoolorToFront(),
      child: Scaffold(
        backgroundColor: const Color(0xFF232F34),
        appBar: AppBar(
          title: const Text('إدارة الألوان',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF232F34),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8, bottom: 5),
              child: FloatingActionButton(
                onPressed: () => _showAddColorModal(context),
                backgroundColor: const Color.fromARGB(255, 59, 79, 92),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
          iconTheme: IconThemeData(
            color: Colors.white, // ← هنا تغيّر لون أيقونة الهامبرغر
          ),
        ),
        body: BlocBuilder<CoolorCubit, CoolorState>(
          builder: (context, state) {
            if (state is CoolorLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CoolorError) {
              return Center(
                child: Text(
                  state.message ?? "",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 193, 104, 98),
                  ),
                ),
              );
            } else if (state is CoolorLoaded) {
              final colors = state.coolor;
              if (colors.isEmpty) {
                return const Center(
                    child: Text(
                  'لا توجد ألوان بعد',
                ));
              }

              return Directionality(
                textDirection: TextDirection.rtl,
                child: ListView.separated(
                  itemCount: colors.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final color = colors[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.color_lens,
                        color: Color.fromARGB(255, 169, 177, 224),
                      ),
                      title: Text(
                        color.name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
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
                                    "هل أنت متأكد أنك تريد حذف هذا اللون؟"),
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
                            context.read<CoolorCubit>().deleteColor(color.id!);
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
