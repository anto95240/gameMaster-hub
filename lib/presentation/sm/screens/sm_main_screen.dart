import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/presentation/sm/screens/sm_players_tab.dart';
import 'package:gamemaster_hub/presentation/core/widgets/custom_app_bar.dart';

class SMMainScreen extends StatefulWidget {
  final int saveId;
  const SMMainScreen({super.key, required this.saveId});

  @override
  State<SMMainScreen> createState() => _SMMainScreenState();
}

class _SMMainScreenState extends State<SMMainScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveLayout.getScreenTypeFromWidth(constraints.maxWidth);
        final isMobileOrTablet = screenType == ScreenType.mobile || screenType == ScreenType.tablet;
        double screenWidth = constraints.maxWidth;
        double fontSize = screenWidth < 400
            ? 14
            : screenWidth < 600
                ? 16
                : 18;

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Soccer Manager',
            onBackPressed: () => context.go('/saves/${widget.saveId}'),
            isMobile: isMobileOrTablet,
            mobileTitleSize: fontSize,
          ),
          body: TabBarView(
            controller: _tabController,
            children: const [
              SMPlayersTab(),
            ],
          ),
        );
      },
    );
  }
}
