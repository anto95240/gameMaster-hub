import 'package:equatable/equatable.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

enum TacticsStatus { initial, loading, loaded, error }

class TacticsSmState extends Equatable {
  final TacticsStatus status;
  final String selectedFormation;
  final Map<String, double> stylesGeneral;
  final Map<String, double> stylesAttack;
  final Map<String, double> stylesDefense;
  final Map<String, JoueurSmWithStats?> assignedPlayersByPoste;
  final Map<int, RoleModeleSm> assignedRolesByPlayerId;
  final String? errorMessage;

  const TacticsSmState({
    this.status = TacticsStatus.initial,
    this.selectedFormation = '4-3-3', 
    this.stylesGeneral = const {},
    this.stylesAttack = const {},
    this.stylesDefense = const {},
    this.assignedPlayersByPoste = const {},
    this.assignedRolesByPlayerId = const {},
    this.errorMessage,
  });

  TacticsSmState copyWith({
    TacticsStatus? status,
    String? selectedFormation,
    Map<String, double>? stylesGeneral,
    Map<String, double>? stylesAttack,
    Map<String, double>? stylesDefense,
    Map<String, JoueurSmWithStats?>? assignedPlayersByPoste,
    Map<int, RoleModeleSm>? assignedRolesByPlayerId,
    String? errorMessage,
  }) {
    return TacticsSmState(
      status: status ?? this.status,
      selectedFormation: selectedFormation ?? this.selectedFormation,
      stylesGeneral: stylesGeneral ?? this.stylesGeneral,
      stylesAttack: stylesAttack ?? this.stylesAttack,
      stylesDefense: stylesDefense ?? this.stylesDefense,
      assignedPlayersByPoste: assignedPlayersByPoste ?? this.assignedPlayersByPoste,
      assignedRolesByPlayerId: assignedRolesByPlayerId ?? this.assignedRolesByPlayerId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedFormation,
        stylesGeneral,
        stylesAttack,
        stylesDefense,
        assignedPlayersByPoste,
        assignedRolesByPlayerId,
        errorMessage,
      ];
}