import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:achei_pet/controllers/usuario_controller.dart';
import 'package:achei_pet/telas/nav_bar.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:achei_pet/widgets/botao_formatado.dart';
import 'package:achei_pet/widgets/campo_formulario.dart';
import 'package:achei_pet/widgets/texto_formatado.dart';

class TelaCadastroUsuario extends StatefulWidget {
  const TelaCadastroUsuario({super.key});

  @override
  State<TelaCadastroUsuario> createState() => _TelaCadastroUsuarioState();
}

class _TelaCadastroUsuarioState extends State<TelaCadastroUsuario> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  XFile? _imagemSelecionada;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _escolherImagem() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      setState(() {
        _imagemSelecionada = imagem;
      });
    }
  }

  DecorationImage? _obterImagemDeFundo() {
    if (_imagemSelecionada != null) {
      if (kIsWeb) {
        return DecorationImage(image: NetworkImage(_imagemSelecionada!.path), fit: BoxFit.cover);
      } else {
        return DecorationImage(image: FileImage(File(_imagemSelecionada!.path)), fit: BoxFit.cover);
      }
    }
    return null;
  }

  Future<void> _criarConta() async {
    if (_formKey.currentState!.validate()) {
      // Validação extra: As senhas precisam ser iguais
      if (_senhaController.text != _confirmarSenhaController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('As senhas não coincidem!'),
            backgroundColor: Cores.vermehoPerdido,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      await UsuarioController.cadastrarUsuario(
        nome: _nomeController.text,
        email: _emailController.text,
        telefone: _telefoneController.text,
        senha: _senhaController.text,
        fotoUrl: _imagemSelecionada?.path,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso! Bem-vindo(a)!'),
          backgroundColor: Cores.verdeEncontrado,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Limpa a pilha e vai pra Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TelaPrincipal()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.corFundo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TextoFormatado(texto: 'Criar Conta', fontSize: 24),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Foto de Perfil do Usuário
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Cores.botaoGeral, width: 2),
                        image: _obterImagemDeFundo(),
                      ),
                      child: _imagemSelecionada == null
                          ? const Icon(Icons.person, size: 70, color: Cores.iconesOpacos)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 5,
                      child: GestureDetector(
                        onTap: _escolherImagem,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Cores.botaoGeral,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Adicionar foto (Opcional)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Cores.cinza, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Campos do Formulário
              CampoFormulario(
                hint: 'Nome Completo',
                controller: _nomeController,
                validator: (value) => value!.isEmpty ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 16),

              CampoFormulario(
                hint: 'E-mail',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Informe seu e-mail';
                  if (!value.contains('@')) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CampoFormulario(
                hint: 'Telefone (WhatsApp)',
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Informe seu telefone' : null,
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CampoFormulario(
                      hint: 'Senha',
                      controller: _senhaController,
                      obscureText: true, // <--- Usando a propriedade nova!
                      validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CampoFormulario(
                      hint: 'Confirmar Senha',
                      controller: _confirmarSenhaController,
                      obscureText: true, // <--- Usando a propriedade nova!
                      validator: (value) => value!.isEmpty ? 'Confirme a senha' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              BotaoFormatado(
                texto: 'Criar Minha Conta',
                altura: 55,
                tamanhoFonte: 18,
                onPressed: _criarConta,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}