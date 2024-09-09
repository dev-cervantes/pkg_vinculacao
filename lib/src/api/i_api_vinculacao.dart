import 'package:pkg_vinculacao/src/models/codigo_vinculacao/codigo_vinculacao.dart';
import 'package:pkg_vinculacao/src/models/dados_aplicativo/dados_aplicativo.dart';

abstract class IApiVinculacao {
  Future<void> vincular(Function(Vinculacao value) onCodigo, Function(DadosAplicativo dadosAplicativo) onVincular, String cpfCnpj);
}