import 'package:flutter/foundation.dart';
import 'package:pkg_vinculacao/src/api/api_vinculacao.dart';
import 'package:pkg_vinculacao/src/api/i_api_vinculacao.dart';
import 'package:pkg_vinculacao/src/models/dados_aplicativo/dados_aplicativo.dart';

class VinculacaoController {
  final IApiVinculacao _apiVinculacao = ApiVinculacao();

  final ValueNotifier<String> codigo = ValueNotifier<String>('');
  final ValueNotifier<int> etapas = ValueNotifier<int>(1);
  final ValueNotifier<DateTime> dataExpiracao = ValueNotifier<DateTime>(DateTime.now());

  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);

  String cpfCnpj = '';

  Future<void> gerarCodigo(Function(DadosAplicativo dadosAplicativo) onVinculado) async {
    try {
      loading.value = true;

      await _apiVinculacao.vincular(
        (value) {
          codigo.value = value.codigo;
          dataExpiracao.value = value.dataExpiracao;
        },
        onVinculado,
        cpfCnpj,
      );

      etapas.value = 2;
    } finally {
      loading.value = false;
    }
  }
}
