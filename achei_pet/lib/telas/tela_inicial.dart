import 'package:achei_pet/controllers/usuario_controller.dart';
import 'package:achei_pet/telas/tela_cadastro_usuario.dart';
import 'package:achei_pet/telas/nav_bar.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:achei_pet/utils/constantes.dart';
import 'package:achei_pet/widgets/botao_formatado.dart';
import 'package:achei_pet/widgets/campo_formulario.dart';
import 'package:achei_pet/widgets/texto_formatado.dart';
import 'package:flutter/material.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _usuarioController = UsuarioController();

  Future<void> _fazerLogin() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    final sucesso = await UsuarioController.fazerLogin(email: email, senha: senha);

    if (!mounted) return;

    if (sucesso) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TelaPrincipal()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail ou senha inválidos.'),
          backgroundColor: Cores.vermehoPerdido,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.corFundo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo gigante
                const Icon(Icons.pets, size: 100, color: Cores.botaoGeral),
                const SizedBox(height: 16),
                const TextoFormatado(
                  texto: Constantes.nomeApp,
                  fontSize: 42,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Conectando pets perdidos\naos seus lares',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Cores.cinza, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 48),

                // Formulário de Login
                CampoFormulario(
                  hint: 'E-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // NOTA: Para a senha ficar com '***', o CampoFormulario precisa ter a prop obscureText.
                // Por enquanto usamos TextFormField padrão para a senha.
                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Senha',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0x4D000000)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botão de Entrar
                BotaoFormatado(
                  texto: 'Entrar',
                  altura: 55,
                  tamanhoFonte: 18,
                  onPressed: _fazerLogin,
                ),

                const SizedBox(height: 24),

                // Link para Cadastrar Usuário
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta?',
                      style: TextStyle(color: Cores.cinza, fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: () {
                        // Faz a navegação para a nova tela
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TelaCadastroUsuario()),
                        );
                      },
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(color: Cores.botaoGeral, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
