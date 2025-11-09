import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_widgets_export.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/sm_blocs_export.dart';

class SMAnalyseTab extends StatefulWidget {
  final int saveId;
  final Game game;
  final int currentTabIndex;

  const SMAnalyseTab({
    super.key,
    required this.saveId,
    required this.game,
    required this.currentTabIndex,
  });

  @override
  State<SMAnalyseTab> createState() => _SMAnalyseTabState();
}

class _SMAnalyseTabState extends State<SMAnalyseTab> {
  List<String> forces = [];
  List<String> faiblesses = [];
  List<String> manques = [];

  @override
  void initState() {
    super.initState();
    _loadAnalyse();
  }

  Future<void> _loadAnalyse() async {
    final result = await SMAnalyseLogic.analyser(
      saveId: widget.saveId,
      bloc: context.read<JoueursSmBloc>(),
      joueurRepo: context.read<StatsJoueurSmRepositoryImpl>(),
      gardienRepo: context.read<StatsGardienSmRepositoryImpl>(),
    );

    setState(() {
      forces = result.forces;
      faiblesses = result.faiblesses;
      manques = result.manques;
    });
  }

  @override
  Widget build(BuildContext context) {
    final joueursState = context.watch<JoueursSmBloc>().state;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: joueursState is JoueursSmLoaded
                  ? SMPlayersHeader(
                      state: joueursState,
                      width: width,
                      currentTabIndex: widget.currentTabIndex,
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // ✅ Utilise Flexible pour éviter les erreurs de layout sur Web
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: AnalyseLayout(
                  forces: forces,
                  faiblesses: faiblesses,
                  manques: manques,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}