import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahya_new_app/Controlls/apiStock.dart';
import 'package:yahya_new_app/model/stock.dart';

import 'stock-state.dart';

class StockCubit extends Cubit<StockState> {
  final ApiStock apiStock;
  List<Stock> movements = [];

  StockCubit({required this.apiStock}) : super(StockInitial());

  // تغيير productId إلى inventoryId، وإضافة movementType للفلاتر
  Future<void> loadMovements({
    int? inventoryId,
    int? movementType,
  }) async {
    emit(StockLoading());
    try {
      movements = await apiStock.fetchStockMovements(
        inventoryId: inventoryId,
        movementType: movementType,
      );
      emit(StockLoaded(movements));
    } catch (e) {
      emit(StockError('حدث خطأ أثناء تحميل الحركات'));
    }
  }

  // إضافة حركة باستخدام inventoryId بدل productId
  Future<void> addMovement({
    required int inventoryId,
    required int quantity,
    String? notes,
  }) async {
    try {
      print(
          "Cubit: بدء إضافة حركة: inventoryId=$inventoryId, quantity=$quantity");

      final newMovement = Stock(
        id: 0,
        inventoryId: inventoryId,
        quantity: quantity,
        notes: notes,
      );

      await apiStock.addStockMovement(newMovement);

      await loadMovements();

      print("Cubit: تم إعادة تحميل الحركات");
    } catch (e) {
      emit(StockError('حدث خطأ أثناء إضافة الحركة'));
    }
  }
}
