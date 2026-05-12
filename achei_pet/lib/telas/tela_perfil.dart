import 'package:flutter/material.dart';

import 'package:achei_pet/models/usuario.dart';
import 'package:achei_pet/controllers/usuario_controller.dart';
import 'package:achei_pet/servicos/sessao_service.dart';
import 'package:achei_pet/telas/tela_editar_perfil.dart';
import 'package:achei_pet/telas/tela_inicial.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:achei_pet/widgets/imagem_app.dart';
import 'package:achei_pet/widgets/texto_formatado.dart';
import 'package:achei_pet/widgets/item_menu_perfil.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  Usuario? _usuario;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final usuario =
        await UsuarioController.buscarUsuarioLogado() ??
        Usuario(
          id: '0',
          nome: 'Usuário Desconhecido',
          email: 'erro@app.com',
          telefonePessoal: '',
        );

    if (!mounted) return;

    setState(() {
      _usuario = usuario;
      _carregando = false;
    });
  }

  void _fazerLogout(BuildContext context) {
    SessaoService.sair();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TelaInicial()),
      (route) => false,
    );
  }

  Future<void> _editarPerfil() async {
    final usuario = _usuario;
    if (usuario == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaEditarPerfil(usuario: usuario),
      ),
    );
    _carregarUsuario();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario;

    return Scaffold(
      backgroundColor: Cores.corFundo,
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        title: const TextoFormatado(texto: 'Meu Perfil', fontSize: 28),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _carregando || usuario == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Avatar do Usuário
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Cores.botaoGeral,
                              width: 3,
                            ),
                            image: ImagemApp.decoration(usuario.fotoUrl),
                          ),
                          child: usuario.fotoUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Cores.iconesOpacos,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _editarPerfil,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Cores.botaoGeral,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dados do Usuário
                  Text(
                    usuario.nome,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.email,
                    style: const TextStyle(fontSize: 16, color: Cores.cinza),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.telefonePessoal,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),

                  // Menu
                  ItemMenuPerfil(
                    icone: Icons.edit_outlined,
                    titulo: 'Editar Perfil',
                    onTap: _editarPerfil,
                  ),
                  ItemMenuPerfil(
                    icone: Icons.notifications_outlined,
                    titulo: 'Notificações',
                    onTap: () {},
                  ),
                  ItemMenuPerfil(
                    icone: Icons.security_outlined,
                    titulo: 'Privacidade e Segurança',
                    onTap: () {},
                  ),
                  ItemMenuPerfil(
                    icone: Icons.help_outline,
                    titulo: 'Ajuda e Suporte',
                    onTap: () {},
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      onTap: () => _fazerLogout(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      tileColor: Colors.white,
                      leading: const Icon(
                        Icons.logout,
                        color: Cores.vermehoPerdido,
                      ),
                      title: const Text(
                        'Sair da Conta',
                        style: TextStyle(
                          color: Cores.vermehoPerdido,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
