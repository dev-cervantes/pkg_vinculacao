import 'package:flutter/foundation.dart';
import 'package:pkg_vinculacao/src/api/api_vinculacao.dart';
import 'package:pkg_vinculacao/src/api/i_api_vinculacao.dart';
import 'package:pkg_vinculacao/src/models/dados_aplicativo/dados_aplicativo.dart';

class VinculacaoController {
  final IApiVinculacao _apiVinculacao = ApiVinculacao();

  ValueNotifier<String> codigo = ValueNotifier<String>('');
  ValueNotifier<int> etapas = ValueNotifier<int>(1);
  ValueNotifier<DateTime> dataExpiracao = ValueNotifier<DateTime>(DateTime.now());

  String cpfCnpj = '';

  Future<void> gerarCodigo(Function(DadosAplicativo dadosAplicativo) onVinculado) async {
    etapas.value = 2;

    await _apiVinculacao.vincular(
          (value) {
        codigo.value = value.codigo;
        dataExpiracao.value = value.dataExpiracao;
      },
      onVinculado,
      cpfCnpj
    );
  }
}
