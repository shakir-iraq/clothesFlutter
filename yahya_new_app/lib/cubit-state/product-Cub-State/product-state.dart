import 'package:yahya_new_app/model/product.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded(this.products);
}

class ProductAdded extends ProductState {}

class ProductUpdated extends ProductState {}

class ProductDeleted extends ProductState {}

class ProductError extends ProductState {
  final String? message;
  ProductError(this.message);
}
