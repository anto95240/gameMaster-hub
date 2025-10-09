import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'presentation/core/blocs/auth/auth_bloc.dart';
import 'presentation/core/blocs/theme/theme_bloc.dart';
import 'data/sm/repositories/joueur_sm_repository_impl.dart';
import 'data/sm/repositories/stats_joueur_sm_repository_impl.dart';
import 'data/sm/datasources/joueur_sm_remote_data_source.dart';
import 'data/sm/datasources/stats_joueur_sm_remote_data_source.dart';

/// ✅ ID global de sauvegarde actuel
/// TODO: plus tard, relier à un SaveBloc ou au compte utilisateur
const int globalSaveId = 1;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String supabaseUrl = '';
  String supabaseKey = '';

  if (!kIsWeb) {
    // 🔹 Mode Mobile/Desktop : charger .env
    await dotenv.load(fileName: ".env");
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  } else {
    // 🔹 Mode Web : tenter dart-define d'abord, sinon fallback .env
    supabaseUrl = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    supabaseKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      await dotenv.load(fileName: ".env");
      supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    }
  }

  // 🚨 Vérification des clés Supabase
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

  // ✅ Initialisation Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  // ✅ Initialisation Hive
  await Hive.initFlutter();
  await Hive.openBox('theme_box');

  final supabaseClient = Supabase.instance.client;

  // ✅ Repositories
  final joueurRepository =
      JoueurSmRepositoryImpl(JoueurSmRemoteDataSourceImpl(supabaseClient));

  final statsRepository =
      StatsJoueurSmRepositoryImpl(StatsJoueurSmRemoteDataSource(supabaseClient));

  // ✅ Lancement de l’app
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(
          create: (_) => JoueursSmBloc(
            joueurRepository: joueurRepository,
            statsRepository: statsRepository,
          )..add(LoadJoueursSmEvent(globalSaveId)), // 👈 Ajout du saveId ici
        ),
      ],
      child: const GameMasterHubApp(),
    ),
  );
}
