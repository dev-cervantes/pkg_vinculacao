class Vinculacao {
  final String codigo;
  final DateTime dataExpiracao;

  Vinculacao({
    required this.codigo,
    required this.dataExpiracao,
  });

  factory Vinculacao.fromMap(Map<String, dynamic> json) => Vinculacao(
        codigo: json['codigo'],
        dataExpiracao: DateTime.parse(json['dataExpiracao']),
      );
}
