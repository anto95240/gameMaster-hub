import 'package:flutter/material.dart';

class AuthTabBar extends StatelessWidget {
  final TabController tabController;
  const AuthTabBar({required this.tabController, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
            color: Theme.of(context).colorScheme.primary, 
            borderRadius: BorderRadius.circular(12)
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        tabs: const [Tab(text: 'Connexion'), Tab(text: 'Inscription')],
      ),
    );
  }
}
