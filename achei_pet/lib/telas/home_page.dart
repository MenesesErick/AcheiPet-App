import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/servicos/pet_service.dart';
import 'package:achei_pet/telas/tela_detalhes_pet.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:achei_pet/utils/constantes.dart';
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

  final TextEditingController _buscaController = TextEditingController();
  String _textoBusca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<Pet> get _petsFiltrados {
    final todos = PetService.getTodos();
    List<Pet> petsPorStatus = switch (_filtroAtual) {
      FiltroPet.TODOS => todos,
      FiltroPet.ENCONTRADOS => todos.where((p) => p.status == StatusPet.ENCONTRADO).toList(),
      FiltroPet.PERDIDOS => todos.where((p) => p.status == StatusPet.PERDIDO).toList(),
    };

    if (_textoBusca.isEmpty) return petsPorStatus;

    final buscaMinuscula = _textoBusca.toLowerCase();

    return petsPorStatus.where((pet) {
      // Busca por Nome
      if (pet.nome.toLowerCase().contains(buscaMinuscula)) return true;

      // Busca por Localização
      if (pet.localizacao.toLowerCase().contains(buscaMinuscula)) return true;

      // Busca por Raça (Ajustado para lidar com o null)
      if (pet.raca != null && pet.raca!.toLowerCase().contains(buscaMinuscula)) return true;

      return false;
    }).toList();
  }

  void _navegarParaDetalhes(Pet pet) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TelaDetalhesPet(pet: pet)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.corFundo,
      appBar: AppBar(
        toolbarHeight: 120,
        centerTitle: true,
        title: const TextoFormatado(texto: Constantes.nomeApp),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 16),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle_outlined, size: 50, color: Colors.black),
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
            CampoBusca(
              controller: _buscaController,
              onChanged: (valor) {
                setState(() {
                  _textoBusca = valor;
                });
              },
            ),
            const SizedBox(height: 17),
            FiltroPets(
              selecionado: _filtroAtual,
              onChanged: (filtro) => setState(() => _filtroAtual = filtro),
            ),
            const SizedBox(height: 29),
            const Text(
              'Ajude um pet a voltar para casa',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Publique um anúncio de pet perdido',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            Expanded(
              child: _petsFiltrados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pets_outlined, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum pet encontrado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _textoBusca.isEmpty ? 'Não há pets cadastrados' : 'Tente outra busca',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _petsFiltrados.length,
                      itemBuilder: (context, index) => CardPet(
                        pet: _petsFiltrados[index],
                        onVerDetalhes: () => _navegarParaDetalhes(_petsFiltrados[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}