import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahya_new_app/cubit-state/product-Cub-State/product-cub.dart';
import 'package:yahya_new_app/model/category.dart';
import 'package:yahya_new_app/model/product.dart';

class ProductDialog extends StatefulWidget {
  final Product? product;
  final List<Categorys> categories;

  const ProductDialog({super.key, this.product, required this.categories});

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  int? _selectedCategoryId;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(
      text: widget.product != null ? widget.product!.price.toString() : '',
    );
    _selectedCategoryId = widget.product?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final categoryId = _selectedCategoryId;
    final cubit = context.read<ProductCubit>();

    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار تصنيف")),
      );
      return;
    }

    if (widget.product == null) {
      // إضافة منتج جديد: الصورة مطلوبة
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الرجاء اختيار صورة")),
        );
        return;
      }

      await cubit.addProduct(
        name: name,
        description: desc,
        price: price,
        categoryId: categoryId,
        imageFilePath: _selectedImage!.path,
      );
    } else {
      // تعديل منتج: الصورة اختيارية
      await cubit.updateProduct(
        id: widget.product!.id,
        name: name,
        description: desc,
        price: price,
        categoryId: categoryId,
        imageFilePath: _selectedImage?.path,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return AlertDialog(
      title: Text(isEditing ? "تعديل منتج" : "إضافة منتج"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "اسم المنتج"),
                validator: (value) =>
                    value == null || value.isEmpty ? "مطلوب" : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "الوصف"),
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "السعر"),
                validator: (value) =>
                    value == null || value.isEmpty ? "مطلوب" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'التصنيف'),
                items: widget.categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value!;
                  });
                },
                validator: (value) => value == null ? 'اختر تصنيفًا' : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("اختر صورة"),
              ),
              const SizedBox(height: 8),
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 100, fit: BoxFit.cover)
              else if (isEditing && widget.product!.imageUrl != null)
                Image.network(
                  widget.product!.imageUrl!.startsWith('http')
                      ? widget.product!.imageUrl!
                      : 'http://192.168.18.3:7045/${widget.product!.imageUrl!}',
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text("فشل تحميل الصورة"),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text("إلغاء"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(isEditing ? "تحديث" : "إضافة"),
          onPressed: _submit,
        ),
      ],
    );
  }
}
