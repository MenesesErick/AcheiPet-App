import 'dart:ui';

import 'package:achei_pet/dados/dados_simulados.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:achei_pet/widgets/campo_busca.dart';
import 'package:achei_pet/widgets/card_pet.dart';
import 'package:achei_pet/widgets/filtro_pet.dart';
import 'package:achei_pet/widgets/texto_formatado.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FiltroPet _filtroAtual = FiltroPet.TODOS;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.corFundo,
      appBar: AppBar(
        toolbarHeight: 120,
        centerTitle: true,
        title: const TextoFormatado(texto: 'AcheiPet'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 16),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.account_circle_outlined,
                size: 50,
                color: Colors.black,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CampoBusca(),
            SizedBox(height: 17),
            FiltroPets(
              selecionado: _filtroAtual,
              onChanged: (filtro) => setState(() => _filtroAtual = filtro),
            ),
            SizedBox(height: 29),
            Text(
              'Ajude um pet a voltar para casa',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Publique um anúncio de pet perdido ou encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: petsMock.length,
                itemBuilder: (context, index) => CardPet(
                  pet: petsMock[index],
                  onVerDetalhes: () {
                    // navegar para tela de detalhes
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
