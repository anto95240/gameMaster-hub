import 'package:equatable/equatable.dart';

abstract class TacticsSmEvent extends Equatable {
  const TacticsSmEvent();

  @override
  List<Object> get props => [];
}

class LoadTactics extends TacticsSmEvent {
  final int saveId;
  const LoadTactics(this.saveId);

  @override
  List<Object> get props => [saveId];
}

class OptimizeTactics extends TacticsSmEvent {
  final int saveId;
  const OptimizeTactics(this.saveId);

  @override
  List<Object> get props => [saveId];
}