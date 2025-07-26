import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahya_new_app/Controlls/apiProduct.dart';
import 'package:yahya_new_app/cubit-state/product-Cub-State/product-state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());

  Future<void> loadProducts() async {
    emit(ProductLoading());
    try {
      final products = await ApiProduct.fetchProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      print("Error in loadProducts: $e");
      emit(ProductError('فشل في تحميل المنتجات'));
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? imageFilePath,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    emit(ProductLoading());
    try {
      await ApiProduct().addProduct(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imageFilePath: imageFilePath,
        imageBytes: imageBytes,
        imageFileName: imageFileName,
      );
      emit(ProductAdded());
      await loadProducts();
    } catch (e) {
      print("Error in addProduct: $e");
      emit(ProductError('فشل في إضافة المنتج'));
    }
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? imageFilePath,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    emit(ProductLoading());
    try {
      await ApiProduct().updateProduct(
        id: id,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imageFilePath: imageFilePath,
        imageBytes: imageBytes,
        imageFileName: imageFileName,
      );
      await loadProducts();
      emit(ProductUpdated());
    } catch (e) {
      emit(ProductError('فشل في تعديل المنتج'));
    }
  }

  Future<void> deleteProduct(int id) async {
    emit(ProductLoading());
    try {
      await ApiProduct().deleteProduct(id);
      emit(ProductDeleted());
      await loadProducts();
    } catch (e) {
      emit(ProductError('فشل في حذف المنتج'));
    }
  }
}
