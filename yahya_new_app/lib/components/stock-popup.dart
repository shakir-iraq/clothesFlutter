import 'package:flutter/material.dart';
import 'package:yahya_new_app/cubit-state/stock-Cub-State/stock-cub.dart';
import 'package:yahya_new_app/model/inventory.dart';

class StockMovementDialog extends StatefulWidget {
  final List<Inventory> inventory;
  final StockCubit stockCubit;
  final int? selectedInventoryId;

  const StockMovementDialog({
    super.key,
    required this.inventory,
    required this.stockCubit,
    this.selectedInventoryId,
  });

  @override
  State<StockMovementDialog> createState() => _StockMovementDialogState();
}

class _StockMovementDialogState extends State<StockMovementDialog> {
  Inventory? selectedInventoryItem;
  int? movementType;
  final quantityController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedInventoryId != null) {
      selectedInventoryItem = widget.inventory
          .firstWhere((inv) => inv.id == widget.selectedInventoryId);
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _saveMovement() async {
    try {
      final qty = int.tryParse(quantityController.text);
      if (selectedInventoryItem == null ||
          movementType == null ||
          qty == null ||
          qty <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تعبئة جميع الحقول بشكل صحيح')),
        );
        return;
      }

      await widget.stockCubit.addMovement(
        inventoryId: selectedInventoryItem!.id,
        quantity: qty * movementType!,
        notes: notesController.text.trim(),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الإضافة: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة حركة جديدة'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // عرض صورة المنتج إذا متوفرة
            if (selectedInventoryItem != null &&
                selectedInventoryItem!.fullImageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    selectedInventoryItem!.fullImageUrl,
                    width: 220,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'اختر من المخزون'),
              value: selectedInventoryItem?.id,
              items: widget.inventory
                  .map((inv) => DropdownMenuItem<int>(
                        value: inv.id,
                        child: Text(
                            '  ${inv.quantity}- ${inv.sizeName} / ${inv.productName} - ${inv.colorName}'),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedInventoryItem =
                      widget.inventory.firstWhere((inv) => inv.id == val);
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'نوع الحركة'),
              value: movementType,
              items: const [
                DropdownMenuItem(value: 1, child: Text('إضافة')),
                DropdownMenuItem(value: -1, child: Text('خصم')),
              ],
              onChanged: (val) {
                setState(() {
                  movementType = val;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'الكمية'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveMovement,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
