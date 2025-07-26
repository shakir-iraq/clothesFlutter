import 'package:yahya_new_app/model/category.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Categorys> categories;
  CategoryLoaded(this.categories);
}

class CategoryDeleted extends CategoryState {}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}
