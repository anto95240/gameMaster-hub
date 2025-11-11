import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/data/data_export.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/domain/sm/services/tactics_optimizer.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_widgets_export.dart';
import '../blocs/sm_blocs_export.dart';

class SMTacticsTab extends StatefulWidget {
  final int saveId;
  final Game game;
  final int currentTabIndex;

  const SMTacticsTab({
    super.key,
    required this.saveId,
    required this.game,
    required this.currentTabIndex,
  });

  @override
  State<SMTacticsTab> createState() => _SMTacticsTabState();
}

class _SMTacticsTabState extends State<SMTacticsTab> {
  String selectedFormation = '4-3-3';
  Map<String, double>? stylesGeneral;
  Map<String, double>? stylesAttack;
  Map<String, double>? stylesDefense;

  Future<void> _onOptimize() async {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Optimisation en cours...')),
      );

      // ✅ CORRECTION : Utilisation des noms de variables et types corrigés
      final optimizer = TacticsOptimizer(
        joueurRepo: context.read<JoueurSmRepositoryImpl>(),
        statsRepo: context.read<StatsJoueurSmRepositoryImpl>(),
        gardienRepo: context.read<StatsGardienSmRepositoryImpl>(),
        roleRepo: context.read<RoleModeleSmRepositoryImpl>(),
        tactiqueModeleRepo: context.read<TactiqueModeleSmRepositoryImpl>(),
        // Injection des nouveaux repos (implémentations)
        instructionGeneralRepo:
            context.read<InstructionGeneralSmRepositoryImpl>(),
        instructionAttaqueRepo:
            context.read<InstructionAttaqueSmRepositoryImpl>(),
        instructionDefenseRepo:
            context.read<InstructionDefenseSmRepositoryImpl>(),
      );
      final result = await optimizer.optimize(saveId: widget.saveId);

      if (!mounted) return;

      final authUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final tactiqueUserRepo = context.read<TactiqueUserSmRepositoryImpl>();
      await tactiqueUserRepo.insert(TactiqueUserSmModel(
        id: 0,
        formation: result.formation,
        modeleId: result.modeleId,
        // ✅ CORRECTION : Typo 'toIso8601String'
        nom: 'Optimisée ${DateTime.now().toIso8601String()}',
        userId: authUserId,
        saveId: widget.saveId,
      ));

      if (!mounted) return;
      
      final tjRepo = context.read<TactiqueJoueurSmRepositoryImpl>();
      for (final entry in result.joueurIdToRoleId.entries) {
        await tjRepo.insert(TactiqueJoueurSmModel(
          id: 0,
          tactiqueId: result.modeleId ?? 0,
          joueurId: entry.key,
          roleId: entry.value,
          userId: authUserId,
          saveId: widget.saveId,
        ));
      }

      if (!mounted) return;

      final genRepo = context.read<InstructionGeneralSmRepositoryImpl>();
      final attRepo = context.read<InstructionAttaqueSmRepositoryImpl>();
      final defRepo = context.read<InstructionDefenseSmRepositoryImpl>();

      // Logique de sauvegarde (les 'orElse' sont importants)
      await genRepo.insertInstruction(InstructionGeneralSmModel(
        id: 0,
        tactiqueId: result.modeleId ?? 0,
        saveId: widget.saveId,
        userId: authUserId,
        largeur: result.styles.general.keys.firstWhere(
            (k) => k.startsWith('Largeur:'),
            orElse: () => 'Largeur: Équilibrée'),
        mentalite: result.styles.general.keys.firstWhere(
            (k) => k.startsWith('Mentalité:'),
            orElse: () => 'Mentalité: Équilibrée'),
        tempo: result.styles.general.keys.firstWhere(
            (k) => k.startsWith('Tempo:'),
            orElse: () => 'Tempo: Normal'),
        fluidite: result.styles.general.keys
            .firstWhere((k) => k.startsWith('Fluidité:'), orElse: () => ''),
        rythmeTravail: result.styles.general.keys.firstWhere(
            (k) => k.startsWith('Rythme de travail:'),
            orElse: () => ''),
        creativite: result.styles.general.keys
            .firstWhere((k) => k.startsWith('Créativité:'), orElse: () => ''),
      ));

      await attRepo.insertInstruction(InstructionAttaqueSmModel(
        id: 0,
        tactiqueId: result.modeleId ?? 0,
        saveId: widget.saveId,
        userId: authUserId,
        stylePasse: result.styles.attack.keys.firstWhere(
            (k) => k.startsWith('Style de passe:'),
            orElse: () => 'Style de passe: Mixte'),
        styleAttaque: result.styles.attack.keys
            .firstWhere((k) => k.startsWith('Style d\'attaque:'), orElse: () => ''),
        attaquants: result.styles.attack.keys
            .firstWhere((k) => k.startsWith('Attaquants:'), orElse: () => ''),
        jeuLarge: result.styles.attack.keys
            .firstWhere((k) => k.startsWith('Jeu large:'), orElse: () => ''),
        jeuConstruction: result.styles.attack.keys.firstWhere(
            (k) => k.startsWith('Jeu de construction:'),
            orElse: () => 'Jeu de construction: Normal'),
        contreAttaque: result.styles.attack.keys.firstWhere(
            (k) => k.startsWith('Contre-attaque:'),
            orElse: () => 'Contre-attaque: Équilibrée'),
      ));

      await defRepo.insertInstruction(InstructionDefenseSmModel(
        id: 0,
        tactiqueId: result.modeleId ?? 0,
        saveId: widget.saveId,
        userId: authUserId,
        pressing: result.styles.defense.keys.firstWhere(
            (k) => k.startsWith('Pressing:'),
            orElse: () => 'Pressing: Normal'),
        styleTacle: result.styles.defense.keys.firstWhere(
            (k) => k.startsWith('Style tacle:'),
            orElse: () => 'Style tacle: Normal'),
        ligneDefensive: result.styles.defense.keys.firstWhere(
            (k) => k.startsWith('Ligne défensive:'),
            orElse: () => 'Ligne défensive: Normale'),
        gardienLibero: result.styles.defense.keys
            .firstWhere((k) => k.startsWith('Gardien libéro:'), orElse: () => ''),
        perteTemps: result.styles.defense.keys
            .firstWhere((k) => k.startsWith('Perte de temps:'), orElse: () => ''),
      ));

      setState(() {
        selectedFormation = result.formation;
        stylesGeneral = result.styles.general;
        stylesAttack = result.styles.attack;
        stylesDefense = result.styles.defense;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tactique optimisée et enregistrée.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur optimisation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);
    final isMobile = screenType == ScreenType.mobile;
    final isTablet = screenType == ScreenType.tablet;

    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = ResponsiveLayout.getHorizontalPadding(width);

    final spacing = (screenType == ScreenType.mobile)
        ? 10.0
        : (screenType == ScreenType.tablet)
            ? 14.0
            : (screenType == ScreenType.laptop)
                ? 18.0
                : 22.0;

    final joueursState = context.watch<JoueursSmBloc>().state;
    final joueursLoaded = joueursState is JoueursSmLoaded
        ? joueursState
        : const JoueursSmLoaded(joueurs: []); // Utilise const []

    // ✅ Mobile & Tablette
    if (isMobile || isTablet) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: spacing / 2, bottom: spacing),
              child: SMPlayersHeader(
                state: joueursLoaded,
                width: width,
                currentTabIndex: widget.currentTabIndex,
                selectedFormation: selectedFormation, // <-- Passe la formation
              ),
            ),
            _buildOptimizeButton(screenType),
            SizedBox(height: spacing * 1.2),
            SizedBox(
              height: isTablet ? 440 : 360,
              child: FootballField(
                formation: selectedFormation,
                isLargeScreen: false,
              ),
            ),
            SizedBox(height: spacing * 1.2),
            _buildStyleCard(isTablet ? 260 : 220),
          ],
        ),
      );
    }

    // ✅ Desktop / Laptop
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: spacing,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SMPlayersHeader(
              state: joueursLoaded,
              width: width,
              currentTabIndex: widget.currentTabIndex,
              selectedFormation: selectedFormation, // <-- Passe la formation
            ),
          ),
          SizedBox(height: spacing),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 0.65,
                      child: FootballField(
                        formation: selectedFormation,
                        isLargeScreen: true,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spacing * 1.4),
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildOptimizeButton(screenType),
                      SizedBox(height: spacing),
                      Expanded(child: _buildStyleCard(null)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton "Optimiser ma tactique"
  Widget _buildOptimizeButton(ScreenType screenType) {
    final height = (screenType == ScreenType.mobile)
        ? 46.0
        : (screenType == ScreenType.tablet)
            ? 50.0
            : (screenType == ScreenType.laptop)
                ? 52.0
                : 56.0;

    final width = (screenType == ScreenType.mobile)
        ? 160.0
        : (screenType == ScreenType.tablet)
            ? 180.0
            : (screenType == ScreenType.laptop)
                ? 200.0
                : 220.0;

    final fontSize = (screenType == ScreenType.mobile)
        ? 14.0
        : (screenType == ScreenType.tablet)
            ? 15.0
            : (screenType == ScreenType.laptop)
                ? 16.0
                : 17.0;

    return Container(
      height: height,
      width: width,
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
          borderRadius: BorderRadius.circular(8),
          onTap: _onOptimize,
          child: Center(
            child: Text(
              'Optimiser',
              style: TextStyle(
                color: Colors.black87,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construit une section de style (Général, Attaque, Défense)
  Widget _buildStyleSection(String title, Map<String, double>? styles) {
    if (styles == null || styles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4dd0e1),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...styles.entries.map((entry) {
            final displayName = entry.key.capitalize();
            final score = entry.value.toStringAsFixed(1);

            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    score,
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Carte de styles tactiques dynamique
  Widget _buildStyleCard(double? height) {
    final bool hasStyles = (stylesGeneral?.isNotEmpty ?? false) ||
        (stylesAttack?.isNotEmpty ?? false) ||
        (stylesDefense?.isNotEmpty ?? false);

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF2d3142),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Styles de jeu optimisés',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (!hasStyles)
            const Expanded(
              child: Center(
                child: Text(
                  'Aucun style optimisé pour le moment. Cliquez sur "Optimiser".',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          if (hasStyles)
            Expanded(
              child: ListView(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildStyleSection(
                          'Général',
                          stylesGeneral,
                        ),
                      ),
                      Expanded(
                        child: _buildStyleSection(
                          'Attaque',
                          stylesAttack,
                        ),
                      ),
                      Expanded(
                        child: _buildStyleSection(
                          'Défense',
                          stylesDefense,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}