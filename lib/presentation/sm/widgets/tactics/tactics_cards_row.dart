import 'package:flutter/material.dart';

class TacticsCardsRow extends StatelessWidget {
  final String selectedFormation;
  final Function(String) onFormationChanged;
  final VoidCallback onOptimize;
  final bool isLargeScreen;
  final bool isMediumScreen;

  const TacticsCardsRow({
    Key? key,
    required this.selectedFormation,
    required this.onFormationChanged,
    required this.onOptimize,
    required this.isLargeScreen,
    required this.isMediumScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isMediumScreen) {
      // 🔹 Mobile: disposition verticale
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormationCard(
            selectedFormation: selectedFormation,
            onFormationChanged: onFormationChanged,
          ),
          const SizedBox(height: 20),
          _StyleCard(),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: _OptimizeButton(onOptimize: onOptimize),
          ),
        ],
      );
    }

    // 🔹 Desktop/Tablet: disposition horizontale avec bouton centré verticalement
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // centre verticalement le contenu
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: isLargeScreen ? 300 : 240,
          child: _FormationCard(
            selectedFormation: selectedFormation,
            onFormationChanged: onFormationChanged,
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: _StyleCard(),
        ),
        const SizedBox(width: 32),
        // ✅ Bouton centré verticalement
        _OptimizeButton(onOptimize: onOptimize),
      ],
    );
  }
}

class _FormationCard extends StatelessWidget {
  final String selectedFormation;
  final Function(String) onFormationChanged;

  const _FormationCard({
    required this.selectedFormation,
    required this.onFormationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final formations = [
      '4-3-3',
      '4-4-2',
      '3-5-2',
      '4-2-3-1',
      '5-3-2',
      '3-4-3',
      '4-1-2-1-2'
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2d3142),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Liste des Formations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 🔹 deux formations par ligne
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.8,
              ),
              itemCount: formations.length,
              itemBuilder: (context, index) {
                final formation = formations[index];
                final isSelected = formation == selectedFormation;
                return _buildFormationItem(formation, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormationItem(String formation, bool isSelected) {
    return InkWell(
      onTap: () => onFormationChanged(formation),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFF4ECDC4).withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF4ECDC4) : Colors.white24,
          ),
        ),
        child: Text(
          formation,
          style: TextStyle(
            color: isSelected ? const Color(0xFF4ECDC4) : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2d3142),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Liste des Styles de jeu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

class _OptimizeButton extends StatelessWidget {
  final VoidCallback onOptimize;

  const _OptimizeButton({required this.onOptimize});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, // ✅ taille fixe pour bien centrer verticalement
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4dd0e1), Color(0xFFffeb3b)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOptimize,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: const Text(
              'Optimiser',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
