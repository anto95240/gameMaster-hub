import 'package:flutter_bloc/flutter_bloc.dart';

class ExempleCubit extends Cubit<int> {
  ExempleCubit() : super(0);
  void increment() => emit(state + 1);
}
