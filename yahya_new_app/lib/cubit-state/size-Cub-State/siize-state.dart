import 'package:yahya_new_app/model/size.dart';

abstract class SiizeState {}

class SiizeInitial extends SiizeState {}

class SiizeLoading extends SiizeState {}

class SiizeLoaded extends SiizeState {
  final List<Siize> size;
  SiizeLoaded(this.size);
}

class SiizeDeleted extends SiizeState {}

class SiizeError extends SiizeState {
  final String? message;
  SiizeError(this.message);
}
