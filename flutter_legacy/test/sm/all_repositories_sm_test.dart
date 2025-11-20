import 'package:flutter_test/flutter_test.dart';

// ===================== MODELS =====================
class InstructionAttaqueSmModel {
  final String nom;
  InstructionAttaqueSmModel(this.nom);
}

class InstructionDefenseSmModel {
  final String nom;
  InstructionDefenseSmModel(this.nom);
}

class InstructionGeneralSmModel {
  final String nom;
  InstructionGeneralSmModel(this.nom);
}

class RoleModeleSmModel {
  final String nom;
  RoleModeleSmModel(this.nom);
}

class StatsJoueurSmModel {
  final String nom;
  StatsJoueurSmModel(this.nom);
}

class TactiqueModeleSmModel {
  final String nom;
  TactiqueModeleSmModel(this.nom);
}

// ===================== REMOTE DATA SOURCES MOCK =====================
class InstructionAttaqueSmRemoteDataSourceImpl {
  Future<InstructionAttaqueSmModel> getInstruction(int id) async {
    return InstructionAttaqueSmModel('Attaque Test');
  }
}

class InstructionDefenseSmRemoteDataSourceImpl {
  Future<InstructionDefenseSmModel> getInstruction(int id) async {
    return InstructionDefenseSmModel('Defense Test');
  }
}

class InstructionGeneralSmRemoteDataSourceImpl {
  Future<InstructionGeneralSmModel> getInstruction(int id) async {
    return InstructionGeneralSmModel('General Test');
  }
}

class RoleModeleSmRemoteDataSourceImpl {
  Future<RoleModeleSmModel> getRole(int id) async {
    return RoleModeleSmModel('Role Test');
  }
}

class StatsJoueurSmRemoteDataSourceImpl {
  Future<StatsJoueurSmModel> getStats(int id) async {
    return StatsJoueurSmModel('Joueur Test');
  }
}

class TactiqueModeleSmRemoteDataSourceImpl {
  Future<TactiqueModeleSmModel> getTactique(int id) async {
    return TactiqueModeleSmModel('Tactique Test');
  }
}

// ===================== REPOSITORIES =====================
class InstructionAttaqueSmRepositoryImpl {
  final InstructionAttaqueSmRemoteDataSourceImpl remote;
  InstructionAttaqueSmRepositoryImpl(this.remote);

  Future<InstructionAttaqueSmModel> getInstruction(int id) => remote.getInstruction(id);
}

class InstructionDefenseSmRepositoryImpl {
  final InstructionDefenseSmRemoteDataSourceImpl remote;
  InstructionDefenseSmRepositoryImpl(this.remote);

  Future<InstructionDefenseSmModel> getInstruction(int id) => remote.getInstruction(id);
}

class InstructionGeneralSmRepositoryImpl {
  final InstructionGeneralSmRemoteDataSourceImpl remote;
  InstructionGeneralSmRepositoryImpl(this.remote);

  Future<InstructionGeneralSmModel> getInstruction(int id) => remote.getInstruction(id);
}

class RoleModeleSmRepositoryImpl {
  final RoleModeleSmRemoteDataSourceImpl remote;
  RoleModeleSmRepositoryImpl(this.remote);

  Future<RoleModeleSmModel> getRole(int id) => remote.getRole(id);
}

class StatsJoueurSmRepositoryImpl {
  final StatsJoueurSmRemoteDataSourceImpl remote;
  StatsJoueurSmRepositoryImpl(this.remote);

  Future<StatsJoueurSmModel> getStats(int id) => remote.getStats(id);
}

class TactiqueModeleSmRepositoryImpl {
  final TactiqueModeleSmRemoteDataSourceImpl remote;
  TactiqueModeleSmRepositoryImpl(this.remote);

  Future<TactiqueModeleSmModel> getTactique(int id) => remote.getTactique(id);
}

// ===================== TESTS =====================
void main() {
  group('SM Repositories', () {
    final attaqueRepo = InstructionAttaqueSmRepositoryImpl(InstructionAttaqueSmRemoteDataSourceImpl());
    final defenseRepo = InstructionDefenseSmRepositoryImpl(InstructionDefenseSmRemoteDataSourceImpl());
    final generalRepo = InstructionGeneralSmRepositoryImpl(InstructionGeneralSmRemoteDataSourceImpl());
    final roleRepo = RoleModeleSmRepositoryImpl(RoleModeleSmRemoteDataSourceImpl());
    final statsRepo = StatsJoueurSmRepositoryImpl(StatsJoueurSmRemoteDataSourceImpl());
    final tactiqueRepo = TactiqueModeleSmRepositoryImpl(TactiqueModeleSmRemoteDataSourceImpl());

    test('Instruction Attaque', () async {
      final instruction = await attaqueRepo.getInstruction(1);
      expect(instruction.nom, 'Attaque Test');
    });

    test('Instruction Defense', () async {
      final instruction = await defenseRepo.getInstruction(1);
      expect(instruction.nom, 'Defense Test');
    });

    test('Instruction General', () async {
      final instruction = await generalRepo.getInstruction(1);
      expect(instruction.nom, 'General Test');
    });

    test('Role Modele', () async {
      final role = await roleRepo.getRole(1);
      expect(role.nom, 'Role Test');
    });

    test('Stats Joueur', () async {
      final stats = await statsRepo.getStats(1);
      expect(stats.nom, 'Joueur Test');
    });

    test('Tactique Modele', () async {
      final tactique = await tactiqueRepo.getTactique(1);
      expect(tactique.nom, 'Tactique Test');
    });
  });
}
