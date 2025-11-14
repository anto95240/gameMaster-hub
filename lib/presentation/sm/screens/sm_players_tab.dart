import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/sm_blocs_export.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_widgets_export.dart';

class SMPlayersTab extends StatefulWidget {
  final int saveId;
  final int currentTabIndex;

  const SMPlayersTab({
    Key? key,
    required this.saveId,
    required this.currentTabIndex,
  }) : super(key: key);

  @override
  _SMPlayersTabState createState() => _SMPlayersTabState();
}

class _SMPlayersTabState extends State<SMPlayersTab> {
  @override
  void initState() {
    super.initState();
    context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(widget.saveId));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = ResponsiveLayout.getHorizontalPadding(width);

    final joueursState = context.watch<JoueursSmBloc>().state;

    if (joueursState is! JoueursSmLoaded) {
      if (joueursState is JoueursSmError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Erreur: ${joueursState.message}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      }
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
            child: SMPlayersHeader(
              state: joueursState,
              width: width,
              currentTabIndex: widget.currentTabIndex,
            ),
          ),
          
          SMPlayersFilters(
            state: joueursState,
            width: width,
          ),
          const SizedBox(height: 20),
          SMPlayersGrid(
            state: joueursState,
            width: width,
            saveId: widget.saveId,
          ),
        ],
      ),
    );
  }
}