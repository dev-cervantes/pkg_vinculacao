import 'package:pkg_vinculacao/src/enums/aplicativo_enum.dart';

class DadosAplicativo {
  final String idVinculacaoAplicativo;
  final String cpfCnpj;
  final String nomeEmpresa;
  final int idCliente;
  final String? host;
  final String? porta;
  final AplicativoEnum aplicativo;
  final Map<String, dynamic>? detalhes;

  DadosAplicativo({
    required this.idVinculacaoAplicativo,
    required this.cpfCnpj,
    required this.nomeEmpresa,
    required this.idCliente,
    required this.aplicativo,
    required this.host,
    required this.porta,
    required this.detalhes,
  });

  factory DadosAplicativo.fromMap(Map<String, dynamic> json) => DadosAplicativo(
        idVinculacaoAplicativo: json["IdVinculacaoAplicativo"],
        cpfCnpj: json["CpfCnpj"],
        nomeEmpresa: json["NomeEmpresa"],
        idCliente: json["IdCliente"],
        aplicativo: AplicativoEnum.getByValue(json["Aplicativo"]),
        host: json["Host"],
        porta: json["Porta"],
        detalhes: json["Detalhes"],
      );
}
