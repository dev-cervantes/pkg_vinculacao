import 'package:pkg_vinculacao/src/enums/aplicativo_enum.dart';

class DadosAplicativo {
  final String cpfCnpj;
  final String nomeEmpresa;
  final String? host;
  final String? porta;
  final AplicativoEnum aplicativo;
  final Map<String, dynamic>? detalhes;

  DadosAplicativo({
    required this.cpfCnpj,
    required this.nomeEmpresa,
    required this.aplicativo,
    required this.host,
    required this.porta,
    required this.detalhes,
  });

  factory DadosAplicativo.fromMap(Map<String, dynamic> json) => DadosAplicativo(
        cpfCnpj: json["CpfCnpj"],
        nomeEmpresa: json["NomeEmpresa"],
        aplicativo: AplicativoEnum.getByValue(json["Aplicativo"]),
        host: json["Host"],
        porta: json["Porta"],
        detalhes: json["Detalhes"],
      );
}
