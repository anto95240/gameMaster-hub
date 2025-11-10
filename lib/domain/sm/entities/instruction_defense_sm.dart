class InstructionDefenseSm {
  final int id;
  final int tactiqueId;
  final int saveId;
  final String? userId;
  final String? pressing;
  final String? styleTacle;
  final String? ligneDefensive;
  final String? gardienLibero;
  final String? perteTemps;

  InstructionDefenseSm({
    required this.id,
    required this.tactiqueId,
    required this.saveId,
    this.userId,
    this.pressing = '',
    this.styleTacle = '',
    this.ligneDefensive = '',
    this.gardienLibero = '',
    this.perteTemps = '',
  });
}
