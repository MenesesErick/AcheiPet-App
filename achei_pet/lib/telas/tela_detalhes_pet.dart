import 'package:flutter/material.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:achei_pet/widgets/imagem_app.dart';

class TelaDetalhesPet extends StatelessWidget {
  final Pet pet;

  const TelaDetalhesPet({super.key, required this.pet});

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
            ImagemApp.carregar(
              pet.imagemUrl,
              width: double.infinity,
              height: 300,
              placeholderIconSize: 80,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  _buildInfoSection(
                    icon: Icons.location_on_outlined,
                    titulo: 'Localização',
                    conteudo: pet.localizacao,
                  ),

                  const SizedBox(height: 16),

                  _buildInfoSection(
                    icon: Icons.description_outlined,
                    titulo: 'Descrição',
                    conteudo: pet.descricao,
                  ),

                  const SizedBox(height: 16),

                  _buildInfoSection(
                    icon: Icons.pets_outlined,
                    titulo: 'Raça',
                    conteudo:
                        pet.raca ??
                        'Não informada', // Lidando com a possibilidade de null
                  ),

                  const SizedBox(height: 16),

                  _buildInfoSection(
                    icon: Icons.perm_identity,
                    titulo: 'Nome do Dono / Responsável',
                    conteudo: pet.nomeDono,
                  ),

                  const SizedBox(height: 16),

                  _buildInfoSection(
                    icon: Icons.phone_android_outlined,
                    titulo: 'Telefone para Contato',
                    conteudo: pet.telefoneContato, // Exibindo o novo campo
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Funcionalidade de compartilhamento em desenvolvimento',
                                ),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Funcionalidade de contato em desenvolvimento',
                                ),
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
          style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
        ),
      ],
    );
  }
}
