import 'package:yahya_new_app/model/inventory.dart';

abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<Inventory> inventories;
  InventoryLoaded(this.inventories);
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
}

class InventorySuccess extends InventoryState {
  final String message;
  InventorySuccess(this.message);
}

class InventoryAdded extends InventoryState {
  final String message;
  InventoryAdded(this.message);
}
