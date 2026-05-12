import 'package:achei_pet/models/usuario.dart';
import 'package:achei_pet/controllers/usuario_controller.dart';
import 'package:achei_pet/utils/constantes.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:achei_pet/widgets/botao_formatado.dart';
import 'package:achei_pet/widgets/campo_formulario.dart';
import 'package:achei_pet/widgets/imagem_app.dart';
import 'package:achei_pet/widgets/texto_formatado.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TelaEditarPerfil extends StatefulWidget {
  final Usuario usuario;

  const TelaEditarPerfil({super.key, required this.usuario});

  @override
  State<TelaEditarPerfil> createState() => _TelaEditarPerfilState();
}

class _TelaEditarPerfilState extends State<TelaEditarPerfil> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefoneController;

  XFile? _novaImagem;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _emailController = TextEditingController(text: widget.usuario.email);
    _telefoneController = TextEditingController(
      text: widget.usuario.telefonePessoal,
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _escolherImagem() async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(source: ImageSource.gallery);
    if (imagem != null) {
      setState(() => _novaImagem = imagem);
    }
  }

  DecorationImage? _obterImagemDeFundo() =>
      ImagemApp.decoration(_novaImagem?.path ?? widget.usuario.fotoUrl);

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final usuarioAtualizado = await UsuarioController.atualizarPerfil(
      usuarioOriginal: widget.usuario,
      nome: _nomeController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
      novaFotoUrl: _novaImagem?.path,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil atualizado com sucesso!'),
        backgroundColor: Cores.verdeEncontrado,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context, usuarioAtualizado);
  }

  @override
  Widget build(BuildContext context) {
    final temImagem =
        _novaImagem != null ||
        (widget.usuario.fotoUrl != null && widget.usuario.fotoUrl!.isNotEmpty);

    return Scaffold(
      backgroundColor: Cores.corFundo,
      appBar: AppBar(
        toolbarHeight: 120,
        centerTitle: true,
        title: Column(
          children: const [
            TextoFormatado(texto: Constantes.nomeApp),
            SizedBox(height: 4),
            Text(
              'Editar Perfil',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar com botão de troca de foto
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Cores.botaoGeral, width: 3),
                        image: _obterImagemDeFundo(),
                      ),
                      child: temImagem
                          ? null
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Cores.iconesOpacos,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _escolherImagem,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Cores.botaoGeral,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              CampoFormulario(
                hint: 'Nome',
                controller: _nomeController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 16),

              CampoFormulario(
                hint: 'E-mail',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe seu e-mail' : null,
              ),
              const SizedBox(height: 16),

              CampoFormulario(
                hint: 'Telefone',
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe seu telefone'
                    : null,
              ),

              const SizedBox(height: 40),

              Center(
                child: BotaoFormatado(
                  texto: 'Salvar Alterações',
                  largura: 250,
                  altura: 55,
                  tamanhoFonte: 18,
                  onPressed: _salvar,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
