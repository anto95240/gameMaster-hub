import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:gamemaster_hub/app.dart';
import 'package:gamemaster_hub/data/core/datasourses/save_datasource.dart';
import 'package:gamemaster_hub/data/core/repositories/game_repository_impl.dart';
import 'package:gamemaster_hub/data/core/repositories/save_repository_impl.dart';

// ⚽️ Données Football Manager
import 'package:gamemaster_hub/data/sm/datasources/joueur_sm_remote_data_source.dart';
import 'package:gamemaster_hub/data/sm/datasources/stats_joueur_sm_remote_data_source.dart';
import 'package:gamemaster_hub/data/sm/datasources/stats_gardien_sm_remote_data_source.dart';
import 'package:gamemaster_hub/data/sm/repositories/joueur_sm_repository_impl.dart';
import 'package:gamemaster_hub/data/sm/repositories/stats_joueur_sm_repository_impl.dart';
import 'package:gamemaster_hub/data/sm/repositories/stats_gardien_sm_repository_impl.dart';

import 'package:gamemaster_hub/domain/core/repositories/game_repository.dart';
import 'package:gamemaster_hub/domain/core/repositories/save_repository.dart';
import 'package:gamemaster_hub/presentation/core/blocs/auth/auth_bloc.dart';
import 'package:gamemaster_hub/presentation/core/blocs/game/game_bloc.dart';
import 'package:gamemaster_hub/presentation/core/blocs/theme/theme_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String supabaseUrl = '';
  String supabaseKey = '';

  // 🔹 Chargement de la config Supabase
  if (!kIsWeb) {
    await dotenv.load(fileName: ".env");
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  } else {
    supabaseUrl = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    supabaseKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      await dotenv.load(fileName: ".env");
      supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    }
  }

  // 🔸 Si erreur de clé → écran clair
  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Erreur : Supabase URL ou Key non définie.\n'
              'Mobile/Desktop → .env\n'
              'Web prod → --dart-define\n'
              'Web dev → fallback .env',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        ),
      ),
    );
    return;
  }

  // 🔹 Initialisation
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  await Hive.initFlutter();
  await Hive.openBox('theme_box');

  final supabaseClient = Supabase.instance.client;

  // 🔹 Repositories
  final saveRepository = SaveRepositoryImpl(SaveDatasource(supabaseClient));
  final gameRepository = GameRepositoryImpl(supabaseClient);

  final joueurRepository =
      JoueurSmRepositoryImpl(JoueurSmRemoteDataSourceImpl(supabaseClient));
  final statsRepository =
      StatsJoueurSmRepositoryImpl(StatsJoueurSmRemoteDataSource(supabaseClient));

  // 🧤 Repository gardien
  final statsGardienRepository = StatsGardienSmRepositoryImpl(
      StatsGardienSmRemoteDataSource(supabaseClient));

  // 🔹 Lancement de l’app
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SaveRepository>.value(value: saveRepository),
        RepositoryProvider<GameRepository>.value(value: gameRepository),
        RepositoryProvider<JoueurSmRepositoryImpl>.value(value: joueurRepository),
        RepositoryProvider<StatsJoueurSmRepositoryImpl>.value(value: statsRepository),
        RepositoryProvider<StatsGardienSmRepositoryImpl>.value(value: statsGardienRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeBloc()),
          BlocProvider(create: (_) => AuthBloc()),
          BlocProvider(
            create: (_) => JoueursSmBloc(
              joueurRepository: joueurRepository,
              statsRepository: statsRepository,
              gardienRepository: statsGardienRepository, // ✅ AJOUTÉ ICI
            ),
          ),
          BlocProvider(create: (_) => GameBloc(gameRepository)..add(LoadGames())),
        ],
        child: const GameMasterHubApp(),
      ),
    ),
  );
}
