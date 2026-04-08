import 'dart:io';

import 'package:achei_pet/dados/dados_simulados.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/utils/constantes.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:achei_pet/widgets/botao_formatado.dart';
import 'package:achei_pet/widgets/campo_formulario.dart';
import 'package:achei_pet/widgets/texto_formatado.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _racaController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _nomeDonoController = TextEditingController();

  StatusPet _statusSelecionado = StatusPet.PERDIDO;
  XFile? _imagemSelecionada;

  @override
  void dispose() {
    _nomeController.dispose();
    _racaController.dispose();
    _telefoneController.dispose();
    _localizacaoController.dispose();
    _descricaoController.dispose();
    _nomeDonoController.dispose();
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

  void _salvarCadastro() {
    if (_imagemSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, adicione uma foto do pet do seu computador.'),
          backgroundColor: Cores.vermehoPerdido,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final novoPet = Pet(
        id: DateTime.now().toString(),
        usuarioId: usuarioLogadoId, // ID fixo de quem está usando o app agora
        nome: _nomeController.text.isEmpty ? 'Pet sem nome' : _nomeController.text,
        raca: _racaController.text.isEmpty ? null : _racaController.text, // Tratando como opcional
        descricao: _descricaoController.text,
        localizacao: _localizacaoController.text,
        imagemUrl: _imagemSelecionada!.path,
        status: _statusSelecionado,
        nomeDono: _nomeDonoController.text,
        telefoneContato: _telefoneController.text, // Mapeado para o novo modelo
      );

      petsMock.add(novoPet);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pet cadastrado com sucesso!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          backgroundColor: Cores.verdeEncontrado,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _formKey.currentState!.reset();
      setState(() {
        _statusSelecionado = StatusPet.PERDIDO;
        _imagemSelecionada = null;
        _nomeController.clear();
        _racaController.clear();
        _telefoneController.clear();
        _localizacaoController.clear();
        _descricaoController.clear();
        _nomeDonoController.clear();
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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        image: _obterImagemDeFundo(),
                      ),
                      child: _imagemSelecionada == null
                          ? const Icon(Icons.pets, size: 80, color: Cores.iconesOpacos)
                          : null,
                    ),
                    Positioned(
                      bottom: 5,
                      right: 15,
                      child: GestureDetector(
                        onTap: _escolherImagem,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Cores.botaoGeral,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.photo_library, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CampoFormulario(hint: 'Nome do pet', controller: _nomeController),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CampoFormulario(
                      hint: 'Raça do pet (Opcional)',
                      controller: _racaController,
                      // Removido o validador para tornar opcional
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CampoFormulario(
                      hint: 'Telefone para contato',
                      controller: _telefoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Informe um telefone' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CampoFormulario(
                      hint: 'Digite o nome do dono',
                      controller: _nomeDonoController,
                      keyboardType: TextInputType.text,
                      validator: (value) => value!.isEmpty ? 'Informe o dono' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              CampoFormulario(
                hint: 'Localização (Ex: Taquaralto, Palmas - TO)',
                controller: _localizacaoController,
                validator: (value) => value!.isEmpty ? 'Informe onde foi visto/perdido' : null,
              ),
              const SizedBox(height: 16),

              CampoFormulario(
                hint: 'Digite uma descrição para melhor reconhecimento',
                controller: _descricaoController,
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Adicione uma descrição' : null,
              ),
              const SizedBox(height: 40),

              Center(
                child: BotaoFormatado(
                  texto: 'Salvar Cadastro',
                  largura: 250,
                  altura: 55,
                  tamanhoFonte: 18,
                  onPressed: _salvarCadastro,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}