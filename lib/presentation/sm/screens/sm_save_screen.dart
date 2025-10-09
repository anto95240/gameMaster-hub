import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamemaster_hub/main.dart';
import '../../../domain/core/entities/save.dart';
import '../../core/blocs/auth/auth_bloc.dart';
import '../../core/blocs/theme/theme_bloc.dart';
import '../../core/utils/responsive_layout.dart';
import '../blocs/save/saves_bloc.dart';
import '../blocs/save/saves_event.dart';
import '..//blocs/save/saves_state.dart';

class SMSaveScreen extends StatefulWidget {
  const SMSaveScreen({super.key});

  @override
  State<SMSaveScreen> createState() => _SMSaveScreenState();
}

class _SMSaveScreenState extends State<SMSaveScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les saves à l'ouverture
    context.read<SavesBloc>().add(LoadSavesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenType =
          ResponsiveLayout.getScreenTypeFromWidth(constraints.maxWidth);
      final isMobile = screenType == ScreenType.mobile;
      double screenWidth = constraints.maxWidth;
      double fontSize;

      if (screenWidth < 400) {
        fontSize = 14;
      } else if (screenWidth < 600) {
        fontSize = 16;
      } else if (screenWidth < 900) {
        fontSize = 18;
      } else {
        fontSize = 18;
      }

      return Scaffold(
        appBar: AppBar(
          title: isMobile
              ? const Icon(Icons.save)
              : const Row(
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Mes Sauvegardes'),
                  ],
                ),
          actions: [
            IconButton(
              onPressed: () {
                context.read<ThemeBloc>().add(ToggleTheme());
              },
              icon: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return Icon(
                    state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  );
                },
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthSignOutRequested());
                context.go('/auth');
              },
              icon: const Icon(Icons.account_circle),
            ),
          ],
        ),
        body: BlocBuilder<SavesBloc, SavesState>(
          builder: (context, state) {
            if (state is SavesLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SavesLoadedState) {
              if (state.saves.isEmpty) {
                return const Center(child: Text('Aucune sauvegarde trouvée.'));
              }

              return ListView.builder(
                itemCount: state.saves.length,
                itemBuilder: (context, index) {
                  final save = state.saves[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(save.name),
                      subtitle: Text(
                          'Créée le : ${save.createdAt.toString().split(".").first}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        setState(() {
                          globalSaveId = save.id;
                        });
                        context.go('/sm_main');
                      },
                    ),
                  );
                },
              );
            } else if (state is SavesErrorState) {
              return Center(child: Text('Erreur : ${state.message}'));
            }
            return const Center(child: Text('Chargement...'));
          },
        ),
      );
    });
  }
}
