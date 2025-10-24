import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/core/blocs/theme/theme_bloc.dart';
import 'package:gamemaster_hub/presentation/core/navigation/app_router.dart';
import 'package:gamemaster_hub/presentation/core/themes/app_theme.dart';
import 'package:gamemaster_hub/presentation/core/widgets/update_notify.dart';

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
