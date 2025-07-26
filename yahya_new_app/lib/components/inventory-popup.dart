import 'package:flutter/material.dart';
import 'package:yahya_new_app/cubit-state/inventory-Cub-State/inventory-cub.dart';
import 'package:yahya_new_app/model/Coolor.dart';
import 'package:yahya_new_app/model/inventory.dart';
import 'package:yahya_new_app/model/product.dart';
import 'package:yahya_new_app/model/size.dart';

class AddInventoryPopup extends StatefulWidget {
  final List<Product> products;
  final List<Coolor> coolors;
  final List<Siize> siizes;
  final InventoryCubit inventoryCubit;
  final Inventory? existingInventory; // لتحديد إذا كنا في تعديل

  const AddInventoryPopup({
    Key? key,
    required this.products,
    required this.coolors,
    required this.siizes,
    required this.inventoryCubit,
    this.existingInventory,
  }) : super(key: key);

  @override
  State<AddInventoryPopup> createState() => _AddInventoryPopupState();
}

class _AddInventoryPopupState extends State<AddInventoryPopup> {
  final _formKey = GlobalKey<FormState>();

  Product? selectedProduct;
  Coolor? selectedCoolor;
  Siize? selectedSiize;
  int? quantity;

  @override
  void initState() {
    super.initState();

    if (widget.existingInventory != null) {
      final inv = widget.existingInventory!;
      selectedProduct = widget.products.firstWhere((p) => p.id == inv.productId,
          orElse: () => widget.products.first);
      selectedCoolor = widget.coolors.firstWhere((c) => c.id == inv.coolorId,
          orElse: () => widget.coolors.first);
      selectedSiize = widget.siizes.firstWhere((s) => s.id == inv.siizeId,
          orElse: () => widget.siizes.first);
      quantity = inv.quantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingInventory != null
          ? 'تعديل مخزون'
          : 'إضافة مخزون جديد'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedProduct != null &&
                  selectedProduct!.imageUrl != null &&
                  selectedProduct!.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    selectedProduct!.fullImageUrl!,
                    height: 250,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 150),
                  ),
                ),
              const SizedBox(height: 12), // مسافة بين الصورة وباقي المحتوى

              DropdownButtonFormField<Product>(
                value: selectedProduct,
                decoration: const InputDecoration(labelText: 'اختر المنتج'),
                items: widget.products
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.name),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedProduct = val),
                validator: (val) => val == null ? 'مطلوب اختيار المنتج' : null,
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<Coolor>(
                value: selectedCoolor,
                decoration: const InputDecoration(labelText: 'اختر اللون'),
                items: widget.coolors
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedCoolor = val),
                validator: (val) => val == null ? 'مطلوب اختيار اللون' : null,
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<Siize>(
                value: selectedSiize,
                decoration: const InputDecoration(labelText: 'اختر المقاس'),
                items: widget.siizes
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedSiize = val),
                validator: (val) => val == null ? 'مطلوب اختيار المقاس' : null,
              ),

              const SizedBox(height: 10),

              TextFormField(
                initialValue: quantity?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'الكمية',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => quantity = int.tryParse(val),
                validator: (val) {
                  final v = int.tryParse(val ?? '');
                  if (v == null || v <= 0) {
                    return 'أدخل كمية صحيحة أكبر من صفر';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('إلغاء'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text(widget.existingInventory != null ? 'تحديث' : 'حفظ'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (widget.existingInventory != null) {
                await widget.inventoryCubit.updateInventory(
                  inventoryId: widget.existingInventory!.id,
                  productId: selectedProduct!.id,
                  coolorId: selectedCoolor!.id ?? 0,
                  siizeId: selectedSiize!.id ?? 0,
                  quantity: quantity!,
                );
              } else {
                await widget.inventoryCubit.addInventory(
                  productId: selectedProduct!.id,
                  coolorId: selectedCoolor!.id ?? 0,
                  siizeId: selectedSiize!.id ?? 0,
                  quantity: quantity!,
                );
              }

              Navigator.pop(context);
              await widget.inventoryCubit.loadInventories();
            }
          },
        ),
      ],
    );
  }
}
