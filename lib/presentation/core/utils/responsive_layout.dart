// [lib/presentation/core/utils/responsive_layout.dart]
import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, laptop, laptopL }

class ResponsiveLayout {
  // Breakpoints standards
  static const double mobileBreakpoint = 768;   // < 768px = mobile
  static const double tabletBreakpoint = 1024;  // 768-1023px = tablet
  static const double laptopBreakpoint = 1440;  // 1024-1439px = laptop

  static ScreenType getScreenType(BuildContext context) {
    return getScreenTypeFromWidth(MediaQuery.of(context).size.width);
  }

  static ScreenType getScreenTypeFromWidth(double width) {
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < laptopBreakpoint) {
      return ScreenType.laptop;
    } else {
      return ScreenType.laptopL;
    }
  }

  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  static bool isLaptop(BuildContext context) {
    return getScreenType(context) == ScreenType.laptop;
  }

  static bool isLaptopL(BuildContext context) {
    return getScreenType(context) == ScreenType.laptopL;
  }

  static bool isDesktop(BuildContext context) {
    final type = getScreenType(context);
    return type == ScreenType.laptop || type == ScreenType.laptopL;
  }

  static int getCrossAxisCount(double width) {
    if (width < mobileBreakpoint) {
      return 1;
    } else if (width < tabletBreakpoint) {
      return 2;
    } else if (width < laptopBreakpoint) {
      return 3;
    } else {
      return 4;
    }
  }

  static double getHorizontalPadding(double width) {
    if (width < mobileBreakpoint) {
      return 16;
    } else if (width < tabletBreakpoint) {
      return 24;
    } else if (width < laptopBreakpoint) {
      return 32;
    } else {
      return 48;
    }
  }

  static double getVerticalPadding(double width) {
    if (width < mobileBreakpoint) {
      return 16;
    } else if (width < tabletBreakpoint) {
      return 24;
    } else if (width < laptopBreakpoint) {
      return 32;
    } else {
      return 48;
    }
  }

  // Contraintes pour les cartes de joueurs
  static CardConstraints getPlayerCardConstraints(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return CardConstraints(
          minWidth: 280,
          maxWidth: 400,
          minHeight: 150, // Modifié
          maxHeight: 190, // Modifié
        );
      case ScreenType.tablet:
        return CardConstraints(
          minWidth: 300,
          maxWidth: 380,
          minHeight: 170, // Modifié
          maxHeight: 210, // Modifié
        );
      case ScreenType.laptop:
        return CardConstraints(
          minWidth: 300,
          maxWidth: 400,
          minHeight: 190, // Modifié
          maxHeight: 230, // Modifié
        );
      case ScreenType.laptopL:
        return CardConstraints(
          minWidth: 320,
          maxWidth: 420,
          minHeight: 195, // Modifié
          maxHeight: 250, // Modifié
        );
    }
  }

  // Contraintes pour les cartes de jeux
  static CardConstraints getGameCardConstraints(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return CardConstraints(
          minWidth: 280,
          maxWidth: 500,
          minHeight: 200,
          maxHeight: 240,
        );
      case ScreenType.tablet:
        return CardConstraints(
          minWidth: 300,
          maxWidth: 400,
          minHeight: 220,
          maxHeight: 280,
        );
      case ScreenType.laptop:
        return CardConstraints(
          minWidth: 300,
          maxWidth: 420,
          minHeight: 240,
          maxHeight: 300,
        );
      case ScreenType.laptopL:
        return CardConstraints(
          minWidth: 320,
          maxWidth: 450,
          minHeight: 260,
          maxHeight: 320,
        );
    }
  }

  // Calcul optimisé du nombre de colonnes basé sur les contraintes
  static int calculateOptimalColumns({
    required double availableWidth,
    required CardConstraints constraints,
    required double spacing,
    int maxColumns = 6,
  }) {
    for (int cols = maxColumns; cols >= 1; cols--) {
      final totalSpacing = spacing * (cols - 1);
      final availableForCards = availableWidth - totalSpacing;
      final cardWidth = availableForCards / cols;
      
      if (cardWidth >= constraints.minWidth && cardWidth <= constraints.maxWidth) {
        return cols;
      }
    }
    return 1;
  }
}

class CardConstraints {
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;

  CardConstraints({
    required this.minWidth,
    required this.maxWidth,
    required this.minHeight,
    required this.maxHeight,
  });

  double get optimalWidth => (minWidth + maxWidth) / 2;
  double get optimalHeight => (minHeight + maxHeight) / 2;
  
  double clampWidth(double width) => width.clamp(minWidth, maxWidth);
  double clampHeight(double height) => height.clamp(minHeight, maxHeight);
}