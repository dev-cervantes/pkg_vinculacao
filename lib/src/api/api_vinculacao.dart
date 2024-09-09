
import 'dart:convert';

import 'package:pkg_flutter_utils/extensions.dart';
import 'package:pkg_vinculacao/pkg_vinculacao.dart';
import 'package:pkg_vinculacao/src/api/i_api_vinculacao.dart';
import 'package:pkg_vinculacao/src/models/dados_aplicativo/dados_aplicativo.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiVinculacao implements IApiVinculacao{
  WebSocketChannel? _channel;

  Future<void> _conectarWebSocket(Function(Vinculacao value) onCodigo, Function(DadosAplicativo aplicativo) onVinculado, String cpfCnpj) async {
    _channel ??= IOWebSocketChannel.connect(Uri.parse('ws://localhost:8000/api/v1/gerar-codigo/${cpfCnpj.extractNumbers()}'), headers:  {
      'Chave': 'Z3VpbGhlcm1lbWVwZXJkaWRvbm9nbw=='
    });

    await _channel?.ready;

    _channel?.stream.listen(
      (event) {
        final map = jsonDecode(event.toString());

        final data = map["data"];

        if (map["evento"] == "codigo") {
          onCodigo.call(Vinculacao.fromMap(data));
        } else if (map["evento"] == "vinculacao") {
          onVinculado.call(DadosAplicativo.fromMap(data));
          _fecharWebSocket();
        }
        print (event.toString());
      },
    );
  }

  @override
  Future<void> vincular(Function(Vinculacao value) onCodigo, Function(DadosAplicativo dadosAplicativo) onVincular, String cpfCnpj) async {
    try {
      if (_channel == null) {
        await _conectarWebSocket(onCodigo, onVincular, cpfCnpj);
      } else {
        final object = {"evento": "codigo-expirado"};

        final json = jsonEncode(object);

        _channel!.sink.add(json);
      }
     return;
    } catch (e) {
      _fecharWebSocket();
      throw Exception('Erro ao buscar código: ${e.toString()}');
    }
  }

  void _fecharWebSocket() {
    _channel?.sink.close();
    _channel = null;
  }
}
