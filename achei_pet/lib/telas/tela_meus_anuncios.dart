import 'dart:io';
import 'package:achei_pet/telas/tela_cadastro.dart';
import 'package:achei_pet/telas/tela_detalhes_pet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:achei_pet/utils/constantes.dart';
import 'package:achei_pet/widgets/texto_formatado.dart';
import 'package:achei_pet/servicos/pet_service.dart';
import 'package:achei_pet/servicos/usuario_service.dart';

class TelaMeusAnuncios extends StatefulWidget {
  const TelaMeusAnuncios({super.key});

  @override
  State<TelaMeusAnuncios> createState() => _TelaMeusAnunciosState();
}

class _TelaMeusAnunciosState extends State<TelaMeusAnuncios> {
  List<Pet> _meusAnuncios = [];

  // ✅ Controller para o carrossel
  late PageController _pageController;

  // ✅ Índice da página atual
  int _paginaAtual = 0;

  @override
  void initState() {
    super.initState();
    _carregarMeusAnuncios();

    // ✅ Inicializa o PageController
    _pageController = PageController(
      viewportFraction: 0.85, // 85% da largura da tela
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    // ✅ Sempre limpe o controller
    _pageController.dispose();
    super.dispose();
  }

  void _carregarMeusAnuncios() {
    setState(() {
      _meusAnuncios = PetService.getPorUsuario(UsuarioService.usuarioLogadoId);
    });
  }

  // Função inteligente para carregar a imagem
  Widget _carregarImagem(String url) {
    if (url.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250,
        color: Colors.grey.shade200,
        child: const Icon(Icons.pets, size: 80, color: Colors.grey),
      );
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 250,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 80, color: Colors.grey),
        ),
      );
    } else if (kIsWeb) {
      return Image.network(
        url,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 250,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 80, color: Colors.grey),
        ),
      );
    } else {
      return Image.file(
        File(url),
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 250,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 80, color: Colors.grey),
        ),
      );
    }
  }

  void _deletarAnuncio(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Anúncio?'),
        content: Text('Tem certeza que deseja deletar o anúncio de ${pet.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TelaDetalhesPet(pet: pet)),
            ),
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              PetService.deletar(pet.isarId);
              setState(() {
                _meusAnuncios.remove(pet);

                if (_meusAnuncios.isEmpty) {
                  _paginaAtual = 0;
                } else if (_paginaAtual >= _meusAnuncios.length) {
                  _paginaAtual = _meusAnuncios.length - 1;
                }

                if (_pageController.hasClients) {
                  _pageController.jumpToPage(_paginaAtual);
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Anúncio deletado com sucesso'),
                  backgroundColor: Cores.vermehoPerdido,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _alterarStatus(Pet pet) {
    final novoStatus =
        pet.status == StatusPet.PERDIDO ? StatusPet.ENCONTRADO : StatusPet.PERDIDO;
    final novoStatusTexto = novoStatus == StatusPet.PERDIDO ? 'Perdido' : 'Encontrado';
    final corStatus =
        novoStatus == StatusPet.ENCONTRADO ? Cores.verdeEncontrado : Cores.vermehoPerdido;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Status'),
        content: Text('Deseja marcar ${pet.nome} como $novoStatusTexto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              PetService.atualizarStatus(pet, novoStatus);
              setState(() {
                pet.status = novoStatus;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${pet.nome} marcado como $novoStatusTexto!'),
                  backgroundColor: corStatus,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Confirmar',
              style: TextStyle(color: corStatus, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editarAnuncio(Pet pet) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TelaCadastro(petParaEditar: pet)),
    );
    _carregarMeusAnuncios();
  }

  void _compartilharAnuncio(Pet pet) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartilhando anúncio de ${pet.nome}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      body: _meusAnuncios.isEmpty ? _buildTelaVazia() : _buildCarrossel(),
    );
  }

  // ✅ Widget para tela vazia
  Widget _buildTelaVazia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.announcement_outlined, size: 120, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            'Nenhum anúncio criado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Crie seu primeiro anúncio para ajudar\num pet a voltar para casa',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TelaCadastro()));
            },
            icon: const Icon(Icons.add),
            label: const Text('Criar Anúncio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Cores.botaoGeral,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Widget para o carrossel
  Widget _buildCarrossel() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header com título e botão
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meus Anúncios',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_meusAnuncios.length} anúncio${_meusAnuncios.length > 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TelaCadastro()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Novo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Cores.botaoGeral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),

          // ✅ CARROSSEL DE CARDS
          SizedBox(
            height: 500, // Altura fixa para o carrossel
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _paginaAtual = index;
                });
              },
              itemCount: _meusAnuncios.length,
              itemBuilder: (context, index) {
                final pet = _meusAnuncios[index];
                return _buildCardPet(pet);
              },
            ),
          ),

          const SizedBox(height: 20),

          // ✅ INDICADORES DE PÁGINA (DOTS)
          if (_meusAnuncios.length > 1)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _meusAnuncios.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _paginaAtual == index ? 30 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _paginaAtual == index ? Cores.botaoGeral : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 32),

          // ✅ INFORMAÇÕES DO PET ATUAL
          if (_meusAnuncios.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildInformacoesPetAtual(),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ✅ Card individual do pet (para o carrossel)
  Widget _buildCardPet(Pet pet) {
    final isPerdido = pet.status == StatusPet.PERDIDO;

    return GestureDetector(
      onTap: () {
        // Ao clicar no card, pode fazer algo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pet.nome} - ${pet.descricao}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Stack(
            children: [
              // Imagem de fundo
              Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: _carregarImagem(pet.imagemUrl),
                    ),
                  ),
                ],
              ),

              // Badge de status no topo direito
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPerdido ? Cores.vermehoPerdido : Cores.verdeEncontrado,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    isPerdido ? 'PERDIDO' : 'ENCONTRADO',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              // Overlay escuro na parte inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.raca ?? 'Raça não especificada',
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Informações detalhadas do pet atual
  Widget _buildInformacoesPetAtual() {
    final petAtual = _meusAnuncios[_paginaAtual];
    final isPerdido = petAtual.status == StatusPet.PERDIDO;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome e status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    petAtual.nome,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    petAtual.raca ?? 'Raça não especificada',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isPerdido
                    ? Cores.vermehoPerdido.withOpacity(0.1)
                    : Cores.verdeEncontrado.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPerdido ? 'Perdido' : 'Encontrado',
                style: TextStyle(
                  color: isPerdido ? Cores.vermehoPerdido : Cores.verdeEncontrado,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Localização
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 18, color: Cores.botaoGeral),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                petAtual.localizacao,
                style: const TextStyle(fontSize: 13, color: Cores.cinza),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Descrição
        Text(
          petAtual.descricao,
          style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
        ),

        const SizedBox(height: 20),

        // Botão de alterar status
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _alterarStatus(petAtual),
            icon: Icon(
              isPerdido ? Icons.check_circle_outline : Icons.search,
              size: 20,
            ),
            label: Text(
              isPerdido ? 'Marcar como Encontrado' : 'Marcar como Perdido',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPerdido ? Cores.verdeEncontrado : Cores.vermehoPerdido,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botões de ação
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editarAnuncio(petAtual),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Editar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Cores.botaoGeral,
                  side: const BorderSide(color: Cores.botaoGeral),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _compartilharAnuncio(petAtual),
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Compartilhar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              child: OutlinedButton(
                onPressed: () => _deletarAnuncio(petAtual),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Icon(Icons.delete, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
