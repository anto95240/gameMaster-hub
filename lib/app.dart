import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class GameMasterHubApp extends StatelessWidget {
  const GameMasterHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp.router(
          routerConfig: router,
          title: 'GameMaster Hub',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return UpdateNotifier(
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
