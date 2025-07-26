import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahya_new_app/cubit-state/color-Cub-State%20copy/coolor-cub.dart';
import 'package:yahya_new_app/model/Coolor.dart';

class AddCoolorModal extends StatefulWidget {
  const AddCoolorModal({super.key});

  @override
  State<AddCoolorModal> createState() => _AddCoolorModalState();
}

class _AddCoolorModalState extends State<AddCoolorModal> {
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  final coolor = Coolor(name: controller.text.trim(), id: 0);
                  context.read<CoolorCubit>().createcoolorFromFront(coolor);
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('حفظ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
