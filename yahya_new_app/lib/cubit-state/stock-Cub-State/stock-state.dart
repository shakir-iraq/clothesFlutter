import 'package:yahya_new_app/model/stock.dart';

abstract class StockState {}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<Stock> movements;
  StockLoaded(this.movements);
}

class StockError extends StockState {
  final String message;
  StockError(this.message);
}
