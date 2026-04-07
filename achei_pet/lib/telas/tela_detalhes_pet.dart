import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/utils/cores.dart';

class TelaDetalhesPet extends StatelessWidget {
  final Pet pet;

  const TelaDetalhesPet({super.key, required this.pet});

  // Mesmo método de carregamento de imagem do CardPet
  Widget _carregarImagem(String url) {
    if (url.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        color: Colors.grey.shade200,
        child: const Icon(Icons.pets, size: 80, color: Colors.grey),
      );
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 80, color: Colors.grey),
        ),
      );
    } else if (kIsWeb) {
      return Image.network(
        url,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 80, color: Colors.grey),
        ),
      );
    } else {
      return Image.file(
        File(url),
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 80, color: Colors.grey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPerdido = pet.status == StatusPet.PERDIDO;

    return Scaffold(
      backgroundColor: Cores.corFundo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalhes do Pet',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem do pet em destaque
            _carregarImagem(pet.imagemUrl),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome e Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pet.nome,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isPerdido
                              ? Cores.vermehoPerdido
                              : Cores.verdeEncontrado,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPerdido ? 'Perdido' : 'Encontrado',
                          style: const TextStyle(
                            color: Cores.branco,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Localização
                  _buildInfoSection(
                    icon: Icons.location_on_outlined,
                    titulo: 'Localização',
                    conteudo: pet.localizacao,
                  ),

                  const SizedBox(height: 16),

                  // Descrição
                  _buildInfoSection(
                    icon: Icons.description_outlined,
                    titulo: 'Descrição',
                    conteudo: pet.descricao,
                  ),

                  const SizedBox(height: 16),

                  _buildInfoSection(
                    icon: Icons.pets_outlined,
                    titulo: 'Raça',
                    conteudo: pet.raca,
                  ),

                  const SizedBox(height: 16),

                  _buildInfoSection(
                    icon: Icons.perm_identity,
                    titulo: 'Nome do Dono',
                    conteudo: pet.nomeDono,
                  ),

                  const SizedBox(height: 30),

                  // Botões de ação
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implementar compartilhamento
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade de compartilhamento em desenvolvimento'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Compartilhar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implementar contato com o anunciante
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade de contato em desenvolvimento'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Contatar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Cores.botaoGeral,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para exibir seções de informação
  Widget _buildInfoSection({
    required IconData icon,
    required String titulo,
    required String conteudo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Cores.botaoGeral, size: 20),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          conteudo,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}