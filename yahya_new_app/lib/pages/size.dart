import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahya_new_app/Controlls/apiSiize.dart';
import 'package:yahya_new_app/cubit-state/size-Cub-State/siize-cub.dart';
import 'package:yahya_new_app/cubit-state/size-Cub-State/siize-state.dart';
import 'package:yahya_new_app/model/size.dart';

class SizeListPage extends StatelessWidget {
  const SizeListPage({super.key});

  void _showAddSizeModal(BuildContext context) {
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
                "إضافة قياس جديد",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'اسم القياس',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final siize = Siize(
                      name: controller.text.trim(),
                    ); // ** بدون id **
                    context.read<SiizeCubit>().createSizeFromFront(siize);
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('حفظ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 237, 238, 241),
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
      create: (context) => SiizeCubit(ApiSiize())..getSizeToFront(),
      child: Scaffold(
        backgroundColor: const Color(0xFF232F34),
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, // ← هنا تغيّر لون أيقونة الهامبرغر
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8, bottom: 5),
              child: FloatingActionButton(
                onPressed: () => _showAddSizeModal(context),
                backgroundColor: const Color.fromARGB(255, 59, 79, 92),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
          title: const Text('إدارة التصنيفات',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF232F34),
        ),
        body: BlocBuilder<SiizeCubit, SiizeState>(
          builder: (context, state) {
            if (state is SiizeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SiizeError) {
              return Center(
                child: Text(
                  state.message ?? "",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is SiizeLoaded) {
              final size = state.size;
              if (size.isEmpty) {
                return const Center(child: Text('لا توجد قياسات بعد'));
              }
              return Directionality(
                textDirection: TextDirection.rtl,
                child: ListView.separated(
                  itemCount: size.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final siize = size[index];
                    return ListTile(
                      leading: const Icon(Icons.sanitizer,
                          color: Color.fromARGB(255, 137, 151, 230)),
                      title: Text(
                        siize.name,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
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
                                    "هل أنت متأكد أنك تريد حذف هذا القياس"),
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
                            context.read<SiizeCubit>().deleteSiize(siize.id!);
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
