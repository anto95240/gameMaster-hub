// [lib/presentation/sm/widgets/tactics/field_position_mapper.dart]
import 'package:flutter/material.dart';

class FieldPositionMapper {
  // Coordonnées [x, y] pour chaque poste-clé (ex: 'DC1')
  // Basé sur les zones de l'image "Capture d'écran 2025-11-12 171923.png"
  // Format PAYSAGE : x = axe horizontal (0.0 = gauche), y = axe vertical (0.0 = haut)
  static const Map<String, Map<String, Offset>> _formationPositionMap = {
    '4-4-2': {
      'G': Offset(0.08, 0.5),
      'DG': Offset(0.25, 0.12),
      'DC1': Offset(0.25, 0.38),
      'DC2': Offset(0.25, 0.62),
      'DD': Offset(0.25, 0.88),
      'MG': Offset(0.55, 0.12),
      'MC1': Offset(0.55, 0.38),
      'MC2': Offset(0.55, 0.62),
      'MD': Offset(0.55, 0.88),
      'BUC1': Offset(0.8, 0.38),
      'BUC2': Offset(0.8, 0.62),
    },
    '4-3-1-2': {
      'G': Offset(0.08, 0.5),
      'DG': Offset(0.25, 0.12),
      'DC1': Offset(0.25, 0.38),
      'DC2': Offset(0.25, 0.62),
      'DD': Offset(0.25, 0.88),
      'MC1': Offset(0.5, 0.2), // MC Gauche
      'MC2': Offset(0.45, 0.5), // MDC
      'MC3': Offset(0.5, 0.8), // MC Droit
      'MOC': Offset(0.65, 0.5),
      'BUC1': Offset(0.8, 0.38),
      'BUC2': Offset(0.8, 0.62),
    },
    '4-2-3-1': {
      'G': Offset(0.08, 0.5),
      'DG': Offset(0.25, 0.12),
      'DC1': Offset(0.25, 0.38),
      'DC2': Offset(0.25, 0.62),
      'DD': Offset(0.25, 0.88),
      'MDC1': Offset(0.45, 0.38),
      'MDC2': Offset(0.45, 0.62),
      'MOG': Offset(0.7, 0.12),
      'MOC': Offset(0.7, 0.5),
      'MOD': Offset(0.7, 0.88),
      'BUC': Offset(0.85, 0.5),
    },
    '4-2-2-2': {
      'G': Offset(0.08, 0.5),
      'DG': Offset(0.25, 0.12),
      'DC1': Offset(0.25, 0.38),
      'DC2': Offset(0.25, 0.62),
      'DD': Offset(0.25, 0.88),
      'MDC1': Offset(0.45, 0.38),
      'MDC2': Offset(0.45, 0.62),
      'MOC1': Offset(0.7, 0.38),
      'MOC2': Offset(0.7, 0.62),
      'BUC1': Offset(0.85, 0.38),
      'BUC2': Offset(0.85, 0.62),
    },
    '4-3-3': {
      'G': Offset(0.08, 0.5),
      'DG': Offset(0.25, 0.12),
      'DC1': Offset(0.25, 0.38),
      'DC2': Offset(0.25, 0.62),
      'DD': Offset(0.25, 0.88),
      'MC1': Offset(0.5, 0.25), // MC Gauche
      'MC2': Offset(0.45, 0.5), // MDC
      'MC3': Offset(0.5, 0.75), // MC Droit
      'MOG': Offset(0.75, 0.12),
      'MOD': Offset(0.75, 0.88),
      'BUC': Offset(0.8, 0.5),
    },
    '3-4-3': {
      'G': Offset(0.08, 0.5),
      'DC1': Offset(0.25, 0.2),
      'DC2': Offset(0.25, 0.5),
      'DC3': Offset(0.25, 0.8),
      'MG': Offset(0.55, 0.12),
      'MC1': Offset(0.55, 0.38),
      'MC2': Offset(0.55, 0.62),
      'MD': Offset(0.55, 0.88),
      'MOG': Offset(0.8, 0.12),
      'MOD': Offset(0.8, 0.88),
      'BUC': Offset(0.8, 0.5),
    },
    '3-5-2': {
      'G': Offset(0.08, 0.5),
      'DC1': Offset(0.25, 0.2),
      'DC2': Offset(0.25, 0.5),
      'DC3': Offset(0.25, 0.8),
      'MG': Offset(0.55, 0.12),
      'MDC': Offset(0.45, 0.5),
      'MC1': Offset(0.55, 0.38),
      'MC2': Offset(0.55, 0.62),
      'MD': Offset(0.55, 0.88),
      'BUC1': Offset(0.8, 0.38),
      'BUC2': Offset(0.8, 0.62),
    },
    '3-3-3-1': {
      'G': Offset(0.08, 0.5),
      'DC1': Offset(0.25, 0.2),
      'DC2': Offset(0.25, 0.5),
      'DC3': Offset(0.25, 0.8),
      'MDC1': Offset(0.45, 0.2),
      'MDC2': Offset(0.45, 0.5),
      'MDC3': Offset(0.45, 0.8),
      'MOG': Offset(0.7, 0.12),
      'MOC': Offset(0.7, 0.5),
      'MOD': Offset(0.7, 0.88),
      'BUC': Offset(0.85, 0.5),
    },
    '3-2-4-1': {
      'G': Offset(0.08, 0.5),
      'DC1': Offset(0.25, 0.2),
      'DC2': Offset(0.25, 0.5),
      'DC3': Offset(0.25, 0.8),
      'MDC1': Offset(0.45, 0.38),
      'MDC2': Offset(0.45, 0.62),
      'MOG': Offset(0.7, 0.12),
      'MOC1': Offset(0.7, 0.38),
      'MOC2': Offset(0.7, 0.62),
      'MOD': Offset(0.7, 0.88),
      'BUC': Offset(0.85, 0.5),
    },
  };

  /// Renvoie le mappage pour une formation, avec fallback sur 4-3-3
  static Map<String, Offset> getFormationPositions(String formation) {
    return _formationPositionMap[formation] ?? _formationPositionMap['4-3-3']!;
  }

  /// Noms des postes logiques de l'image (pour les étiquettes)
  /// [x, y, label]
  static const List<List<dynamic>> posteLabels = [
    [0.08, 0.5, 'G'],
    [0.25, 0.12, 'DG'],
    [0.25, 0.38, 'DC'],
    [0.25, 0.62, 'DC'],
    [0.25, 0.88, 'DD'],
    [0.45, 0.25, 'MDG'], // Milieu Défensif Gauche
    [0.45, 0.5, 'MDC'],
    [0.45, 0.75, 'MDD'], // Milieu Défensif Droit
    [0.55, 0.12, 'MG'],
    [0.55, 0.5, 'MC'],
    [0.55, 0.88, 'MD'],
    [0.7, 0.12, 'MOG'],
    [0.7, 0.5, 'MOC'],
    [0.7, 0.88, 'MOD'],
    [0.85, 0.12, 'BUG'],
    [0.85, 0.5, 'BUC'],
    [0.85, 0.88, 'BUD'],
  ];
}