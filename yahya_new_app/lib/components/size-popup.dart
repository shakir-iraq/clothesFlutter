import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahya_new_app/model/size.dart';

import '../cubit-state/size-Cub-State/siize-cub.dart';

class AddSizeModal extends StatefulWidget {
  const AddSizeModal({super.key});

  @override
  State<AddSizeModal> createState() => _AddSizeModalState();
}

class _AddSizeModalState extends State<AddSizeModal> {
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
                  final size = Siize(name: controller.text.trim(), id: 0);
                  context.read<SiizeCubit>().createSizeFromFront(size);
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
