import 'package:flutter/material.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:pkg_flutter_utils/masked.dart';
import 'package:pkg_flutter_utils/validators.dart';
import 'package:pkg_vinculacao/src/controllers/vinculacao/vinculacao_controller.dart';
import 'package:pkg_vinculacao/src/models/dados_aplicativo/dados_aplicativo.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class VinculacaoPage extends StatefulWidget {
  final String nomeAplicativo;
  final Function(DadosAplicativo dadosAplicativo) onVinculado;
  final Function(BuildContext, Exception, StackTrace) onCodigoNaoEncontrado;

  const VinculacaoPage({
    super.key,
    required this.nomeAplicativo,
    required this.onVinculado,
    required this.onCodigoNaoEncontrado,
  });

  @override
  State<VinculacaoPage> createState() => _VinculacaoPageState();
}

class _VinculacaoPageState extends State<VinculacaoPage> with TickerProviderStateMixin {
  final VinculacaoController _controller = VinculacaoController();
  final TextEditingController _cpfCnpjController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return KeyboardListener(
      autofocus: true,
      focusNode: _focus,
      onKeyEvent: (event) async {
        await _save();
      },
      child: Scaffold(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ValueListenableBuilder(
                      valueListenable: _controller.etapas,
                      builder: (_, value, __) {
                        if (value == 1) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Olá! ",
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    "Realize a vinculação com o aplicativo",
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 32,
                                  ),
                                  Text(
                                    'CPF/CNPJ',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 16),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Form(
                                    key: _formKey,
                                    child: SizedBox(
                                      width: 250,
                                      child: TextFormField(
                                        controller: _cpfCnpjController,
                                        decoration: const InputDecoration(hintText: 'Digite o CPF ou CNPJ'),
                                        inputFormatters: [InputMasked.cnpjCpf()],
                                        keyboardType: TextInputType.number,
                                        validator: InputValidator([CnpjCpfValidator()], isRequired: false).validate,
                                        onSaved: (value) {
                                          _controller.cpfCnpj = value!;
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                ],
                              ),
                              Center(
                                child: SizedBox(
                                  width: 200,
                                  child: FilledButton(
                                    onPressed: () async {
                                    await _save();
                                    },
                                    child: const Text('Vincular'),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return ValueListenableBuilder(
                          valueListenable: _controller.codigo,
                          builder: (_, value, __) {
                            if (value.isEmpty) {
                              return const Center(
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                QrImageView(
                                  data: value,
                                  size: 120,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Código de vinculação',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 22,
                                      ),
                                    ),
                                    Text(
                                      value,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: theme.colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 60,
                                      ),
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
                                            _controller.gerarCodigo(widget.onVinculado);
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
      ),
    );
  }

  Future<void> _save() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        _formKey.currentState?.save();
        if (_controller.cpfCnpj.isNotEmpty) {
          await _controller.gerarCodigo(widget.onVinculado);
        }
      }
    } catch (e, s) {
      widget.onCodigoNaoEncontrado(context, e as Exception, s);
      _controller.etapas.value = 1;
    }
  }
}
