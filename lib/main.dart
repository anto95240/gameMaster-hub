import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:gamemaster_hub/app.dart';
import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String supabaseUrl = '';
  String supabaseKey = '';

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

  // Initialisation
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  await Hive.initFlutter();
  await Hive.openBox('theme_box');

  final supabaseClient = Supabase.instance.client;

  // Repositories
  final saveRepository = SaveRepositoryImpl(SaveDatasource(supabaseClient));
  final gameRepository = GameRepositoryImpl(supabaseClient);

  final joueurRepository =
      JoueurSmRepositoryImpl(JoueurSmRemoteDataSourceImpl(supabaseClient));
  final statsRepository =
      StatsJoueurSmRepositoryImpl(StatsJoueurSmRemoteDataSource(supabaseClient));

  // Repository gardien
  final statsGardienRepository = StatsGardienSmRepositoryImpl(
      StatsGardienSmRemoteDataSource(supabaseClient));

  // SM Tactics related repositories
  final roleRepository =
      RoleModeleSmRepositoryImpl(RoleModeleSmRemoteDataSource(supabaseClient));
  final tactiqueModeleRepository = TactiqueModeleSmRepositoryImpl(
      TactiqueModeleSmRemoteDataSource(supabaseClient));
  final tactiqueJoueurRepository = TactiqueJoueurSmRepositoryImpl(
      TactiqueJoueurSmRemoteDataSource(supabaseClient));
  final tactiqueUserRepository = TactiqueUserSmRepositoryImpl(
      TactiqueUserSmRemoteDataSource(supabaseClient));
  final instrGeneralRepository = InstructionGeneralSmRepositoryImpl(
      InstructionGeneralSmRemoteDataSource(supabaseClient));
  final instrAttaqueRepository = InstructionAttaqueSmRepositoryImpl(
      InstructionAttaqueSmRemoteDataSource(supabaseClient));
  final instrDefenseRepository = InstructionDefenseSmRepositoryImpl(
      InstructionDefenseSmRemoteDataSource(supabaseClient));

  // Lancement de l’app
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SaveRepository>.value(value: saveRepository),
        RepositoryProvider<GameRepository>.value(value: gameRepository),
        RepositoryProvider<JoueurSmRepositoryImpl>.value(value: joueurRepository),
        RepositoryProvider<StatsJoueurSmRepositoryImpl>.value(value: statsRepository),
        RepositoryProvider<StatsGardienSmRepositoryImpl>.value(value: statsGardienRepository),
        RepositoryProvider<RoleModeleSmRepositoryImpl>.value(value: roleRepository),
        RepositoryProvider<TactiqueModeleSmRepositoryImpl>.value(
            value: tactiqueModeleRepository),
        RepositoryProvider<TactiqueJoueurSmRepositoryImpl>.value(
            value: tactiqueJoueurRepository),
        RepositoryProvider<TactiqueUserSmRepositoryImpl>.value(
            value: tactiqueUserRepository),
        RepositoryProvider<InstructionGeneralSmRepositoryImpl>.value(
            value: instrGeneralRepository),
        RepositoryProvider<InstructionAttaqueSmRepositoryImpl>.value(
            value: instrAttaqueRepository),
        RepositoryProvider<InstructionDefenseSmRepositoryImpl>.value(
            value: instrDefenseRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeBloc()),
          BlocProvider(create: (_) => AuthBloc()),
          BlocProvider(
            create: (_) => JoueursSmBloc(
              joueurRepository: joueurRepository,
              statsRepository: statsRepository,
              gardienRepository: statsGardienRepository,
            ),
          ),
          BlocProvider(create: (_) => GameBloc(gameRepository)..add(LoadGames())),
          BlocProvider(
            create: (_) => TacticsSmBloc(
              joueurRepo: joueurRepository,
              statsRepo: statsRepository,
              gardienRepo: statsGardienRepository,
              roleRepo: roleRepository,
              tactiqueModeleRepo: tactiqueModeleRepository,
              instructionGeneralRepo: instrGeneralRepository,
              instructionAttaqueRepo: instrAttaqueRepository,
              instructionDefenseRepo: instrDefenseRepository,
              tactiqueUserRepo: tactiqueUserRepository,
              tactiqueJoueurRepo: tactiqueJoueurRepository,
            ),
          ),
        ],        
        child: const GameMasterHubApp(),
      ),
    ),
  );
}
