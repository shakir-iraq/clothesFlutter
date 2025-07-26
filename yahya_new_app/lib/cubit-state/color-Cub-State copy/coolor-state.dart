import 'package:yahya_new_app/model/Coolor.dart';

abstract class CoolorState {}

class CoolorInitial extends CoolorState {}

class CoolorLoading extends CoolorState {}

class CoolorLoaded extends CoolorState {
  final List<Coolor> coolor;
  CoolorLoaded(this.coolor);
}

class CoolorDeleted extends CoolorState {}

class CoolorError extends CoolorState {
  final String? message;
  CoolorError(this.message);
}
