import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahya_new_app/Controlls/apiInventory.dart';
import 'package:yahya_new_app/cubit-state/inventory-Cub-State/inventory-state.dart';
import 'package:yahya_new_app/model/inventory.dart';

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit() : super(InventoryInitial());
  List<Inventory> _allItems = [];
  List<Inventory> _lowStockItems = [];

  List<Inventory> get lowStockItems => _lowStockItems;

  Future<void> loadInventories() async {
    emit(InventoryLoading());
    try {
      final items = await ApiInventory.fetchInventories();
      _allItems = items;
      _lowStockItems = items.where((item) => item.quantity < 10).toList();

      emit(InventoryLoaded(items));
    } catch (e) {
      emit(InventoryError('فشل تحميل المخزون'));
    }
  }

  Future<void> addInventory({
    required int productId,
    required int coolorId,
    required int siizeId,
    required int quantity,
  }) async {
    try {
      emit(InventoryLoading());

      await ApiInventory.addInventory(
          productId, coolorId, siizeId, quantity); // تأكد من هذه الدالة

      emit(InventorySuccess("تم بنجاح")); // حالة نجاح مؤقتة مثلاً
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> updateInventory({
    required int inventoryId,
    required int productId,
    required int coolorId,
    required int siizeId,
    required int quantity,
  }) async {
    try {
      emit(InventoryLoading());

      final response = await ApiInventory.updateInventory(
        id: inventoryId,
        productId: productId,
        coolorId: coolorId,
        siizeId: siizeId,
        quantity: quantity,
      );

      if (response) {
        await loadInventories();
      } else {
        emit(InventoryError('فشل التعديل'));
      }
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> deleteInventory(int inventoryId) async {
    emit(InventoryLoading());
    try {
      await ApiInventory.deleteInventory(inventoryId);
      await loadInventories();
    } catch (e) {
      emit(InventoryError("فشل في حذف المخزون"));
    }
  }
}
