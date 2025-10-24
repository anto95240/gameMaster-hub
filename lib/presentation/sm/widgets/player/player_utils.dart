import 'package:flutter/material.dart';

Color getPositionColor(String position) {
  switch (position) {
    case 'ATT':
    case 'BU':
    case 'MOD':
    case 'MOG':
      return Colors.red;
    case 'MIL':
    case 'MC':
    case 'MDC':
    case 'MOC':
    case 'MD':
    case 'MG':
      return Colors.green;
    case 'DEF':
    case 'DC':
    case 'DL':
    case 'DR':
    case 'DG':
    case 'DD':
    case 'DOG':
    case 'DOD':
      return Colors.blue;
    case 'GK':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

Color getRatingColor(int rating) {
  if (rating >= 85) return Colors.green;
  if (rating >= 80) return Colors.blue;
  return Colors.orange;
}

Color getProgressionColor(int potentiel) {
  if (potentiel >= 90) return Colors.lightGreen;
  if (potentiel >= 80) return Colors.cyan;
  return Colors.amber;
}
