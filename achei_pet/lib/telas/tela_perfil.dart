import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:achei_pet/dados/dados_simulados.dart'; // Para acessar usuarioLogadoId e usuariosMock
import 'package:achei_pet/models/usuario.dart';
import 'package:achei_pet/telas/tela_inicial.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:achei_pet/widgets/texto_formatado.dart';
import 'package:achei_pet/widgets/item_menu_perfil.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  void _fazerLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TelaInicial()),
      (route) => false,
    );
  }

  // Função inteligente para carregar a imagem do perfil (Igual do Pet)
  DecorationImage? _obterImagemDeFundo(String? url) {
    if (url == null || url.isEmpty) return null;

    if (url.startsWith('assets/')) {
      return DecorationImage(image: AssetImage(url), fit: BoxFit.cover);
    } else if (kIsWeb) {
      return DecorationImage(image: NetworkImage(url), fit: BoxFit.cover);
    } else {
      return DecorationImage(image: FileImage(File(url)), fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Encontra quem é o usuário logado usando a variável global
    final Usuario usuarioAtual = usuariosMock.firstWhere(
      (u) => u.id == usuarioLogadoId,
      orElse: () => const Usuario(
        id: '0', 
        nome: 'Usuário Desconhecido', 
        email: 'erro@app.com', 
        telefonePessoal: ''
      ),
    );

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
            icon: const Icon(Icons.settings_outlined, color: Colors.black, size: 30),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // Avatar do Usuário (Dinâmico)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Cores.botaoGeral, width: 3),
                  image: _obterImagemDeFundo(usuarioAtual.fotoUrl),
                ),
                child: usuarioAtual.fotoUrl == null
                    ? const Icon(Icons.person, size: 60, color: Cores.iconesOpacos)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            
            // Dados do Usuário (Dinâmicos do BD Simulado)
            Text(
              usuarioAtual.nome,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              usuarioAtual.email,
              style: const TextStyle(fontSize: 16, color: Cores.cinza),
            ),
            const SizedBox(height: 4),
            Text(
              usuarioAtual.telefonePessoal,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 40),

            // Menu
            ItemMenuPerfil(
              icone: Icons.edit_outlined,
              titulo: 'Editar Perfil',
              onTap: () {},
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                tileColor: Colors.white,
                leading: const Icon(Icons.logout, color: Cores.vermehoPerdido),
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