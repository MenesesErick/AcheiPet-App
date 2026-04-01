import 'package:flutter/material.dart';
import 'package:achei_pet/utils/cores.dart';

// Importe as telas que já existem
import 'package:achei_pet/telas/home_page.dart';
import 'package:achei_pet/telas/tela_cadastro.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceAtual = 0;

  // Lista de telas que serão renderizadas no body.
  // Coloquei placeholders (Center/Text) para as telas que você ainda não criou.
  final List<Widget> _telas = [
    const HomePage(),
    const TelaCadastro(),
    const Center(child: Text('Tela Meus Anúncios em construção...')), 
    const Center(child: Text('Tela de Perfil em construção...')), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O body muda de acordo com o índice selecionado no navbar
      body: _telas[_indiceAtual],
      
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceAtual,
          onTap: (indice) {
            setState(() {
              _indiceAtual = indice;
            });
          },
          type: BottomNavigationBarType.fixed, // fixed garante que todos os ícones apareçam
          backgroundColor: Cores.branco,
          selectedItemColor: Cores.navbarSelected,
          unselectedItemColor: Cores.navbarNotSelected,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_outlined, size: 28),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home, size: 28),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.add_circle_outline, size: 28),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.add_circle, size: 28),
              ),
              label: 'Cadastrar',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.article_outlined, size: 28),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.article, size: 28),
              ),
              label: 'Meus Anúncios',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline, size: 28),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person, size: 28),
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}