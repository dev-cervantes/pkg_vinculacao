import 'package:flutter/material.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:pkg_flutter_utils/masked.dart';
import 'package:pkg_flutter_utils/validators.dart';
import 'package:pkg_vinculacao/src/controllers/vinculacao/vinculacao_controller.dart';
import 'package:pkg_vinculacao/src/models/dados_aplicativo/dados_aplicativo.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';

class VinculacaoPage extends StatefulWidget {
  final nomeAplicativo;
  final Function(DadosAplicativo dadosAplicativo) onVinculado;

  const VinculacaoPage({super.key, required this.nomeAplicativo, required this.onVinculado});

  @override
  State<VinculacaoPage> createState() => _VinculacaoPageState();
}

class _VinculacaoPageState extends State<VinculacaoPage> with TickerProviderStateMixin {
  final VinculacaoController _controller = VinculacaoController();
  final TextEditingController _cpfCnpjController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FlutterLogo(size: 200),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    widget.nomeAplicativo,
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                  )
                ],
              ),
            ),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ValueListenableBuilder(
                    valueListenable: _controller.etapas,
                    builder: (_, value, __) {
                      if (value == 1) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Digite o CPF ou CNPJ para realizar a vinculação com o aplicativo",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                            Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: _cpfCnpjController,
                                decoration: InputDecoration(
                                    labelText: '* CPF/CNPJ',
                                    labelStyle: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    hintText: 'Digite o CPF ou o CNPJ'),
                                inputFormatters: [InputMasked.cnpjCpf()],
                                keyboardType: TextInputType.number,
                                validator: InputValidator([CnpjCpfValidator()], isRequired: false).validate,
                                onSaved: (value) {
                                  _controller.cpfCnpj = value!;
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            FilledButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  _formKey.currentState?.save();
                                  if (_controller.cpfCnpj.isNotEmpty) {
                                    _controller.enviarCpfCnpj(_controller.cpfCnpj, widget.onVinculado);
                                  }
                                }
                              },
                              child: const Text('ENVIAR'),
                            ),
                          ],
                        );
                      }
                      return ValueListenableBuilder(
                        valueListenable: _controller.codigo,
                        builder: (_, value, __) {
                          if (value.isEmpty) return const CircularProgressIndicator();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              QrImageView(
                                data: value,
                                size: 150,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Código de vinculação',
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 30),
                                  ),
                                  Text(
                                    value,
                                    style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 60),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 200,
                                      height: 10,
                                      child: LinearTimer(
                                        key: UniqueKey(),
                                        duration: Duration(seconds: _controller.dataExpiracao.value.difference(DateTime.now()).inSeconds),
                                        color: theme.colorScheme.primary,
                                        backgroundColor: theme.colorScheme.primary.withOpacity(0.3),
                                        forward: false,
                                        onTimerEnd: () {
                                        _controller.gerarNovoCodigo(widget.onVinculado);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
