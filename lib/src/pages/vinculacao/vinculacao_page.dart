import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:pkg_flutter_utils/masked.dart';
import 'package:pkg_flutter_utils/validators.dart';
import 'package:pkg_vinculacao/pkg_vinculacao.dart';
import 'package:pkg_vinculacao/src/controllers/vinculacao/vinculacao_controller.dart';
import 'package:pkg_vinculacao/src/widgets/center_box_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VinculacaoPage extends StatefulWidget {
  final String nomeAplicativo;
  final String svgLogoPath;
  final String svgBackgroundPath;
  final Function(DadosAplicativo dadosAplicativo) onVinculado;
  final Function(BuildContext, Exception, StackTrace) onCodigoNaoEncontrado;

  const VinculacaoPage({
    super.key,
    required this.nomeAplicativo,
    required this.svgLogoPath,
    required this.onVinculado,
    required this.onCodigoNaoEncontrado,
    required this.svgBackgroundPath,
  });

  @override
  State<VinculacaoPage> createState() => _VinculacaoPageState();
}

class _VinculacaoPageState extends State<VinculacaoPage> {
  final VinculacaoController _controller = VinculacaoController();
  final TextEditingController _cpfCnpjController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: theme.colorScheme.primary,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: KeyboardListener(
        autofocus: true,
        focusNode: _focus,
        onKeyEvent: (event) async {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            await _vincular();
          }
        },
        child: Stack(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 0,
              ),
              itemBuilder: (context, index) {
                return SvgPicture.asset(
                  widget.svgBackgroundPath,
                  fit: BoxFit.cover,
                  color: Colors.white.withOpacity(0.2),
                );
              },
            ),
            CenterBox(
              margin: EdgeInsets.zero,
              borderRadius: BorderRadius.zero,
              child: SizedBox(
                height: double.infinity,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          widget.svgLogoPath,
                          height: 200,
                        ),
                        Text(
                          widget.nomeAplicativo,
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 32),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 2,
                          width: 300,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        ValueListenableBuilder(
                          valueListenable: _controller.etapas,
                          builder: (_, etapa, __) {
                            if (etapa == 1) {
                              return _primeiraEtapa();
                            }

                            return _segundaEtapa();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primeiraEtapa() {
    return SizedBox(
      width: 350,
      child: Column(
        children: [
          const Text(
            'Insira os dados para vincular o aplicativo.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: ValueListenableBuilder(
              valueListenable: _controller.loading,
              builder: (_, loading, __) => TextFormField(
                controller: _cpfCnpjController,
                decoration: const InputDecoration(
                  hintText: 'Digite o CPF ou CNPJ',
                  fillColor: Colors.white,
                ),
                enabled: !loading,
                inputFormatters: [InputMasked.cnpjCpf()],
                keyboardType: TextInputType.number,
                validator: InputValidator([CnpjCpfValidator()], isRequired: true).validate,
                onSaved: (value) {
                  _controller.cpfCnpj = value!;
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _vincular,
              label: const Text('Vincular'),
              icon: ValueListenableBuilder(
                valueListenable: _controller.loading,
                builder: (_, loading, __) {
                  if (loading) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    );
                  }

                  return const Icon(Icons.keyboard_double_arrow_right_outlined);
                },
              ),
              iconAlignment: IconAlignment.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _segundaEtapa() {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        QrImageView(
          data: _controller.codigo.value,
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
              _controller.codigo.value,
              style: theme.textTheme.titleLarge?.copyWith(
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
  }

  Future<void> _vincular() async {
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
