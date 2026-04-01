import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:achei_pet/widgets/botao_formatado.dart';
import 'package:achei_pet/widgets/texto_formatado.dart';
import 'package:achei_pet/widgets/campo_formulario.dart';
import 'package:achei_pet/widgets/botao_status.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:achei_pet/dados/dados_simulados.dart';

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

  StatusPet _statusSelecionado = StatusPet.PERDIDO;
  
  // Aqui fica guardada a imagem real que você puxar do seu computador
  XFile? _imagemSelecionada;

  @override
  void dispose() {
    _nomeController.dispose();
    _racaController.dispose();
    _telefoneController.dispose();
    _localizacaoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  // Lógica real de pegar arquivo do computador/celular
  Future<void> _escolherImagem() async {
    final ImagePicker picker = ImagePicker();
    // Abre a janela do Windows/Edge para você escolher o arquivo
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      setState(() {
        _imagemSelecionada = imagem; 
      });
    }
  }

  void _salvarCadastro() {
    // Trava para obrigar a escolha da foto
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
      
      // 1. CRIA O NOVO PET COM OS DADOS DO FORMULÁRIO
      final novoPet = Pet(
        id: DateTime.now().toString(), // Gera um ID único na gambiarra
        nome: _nomeController.text.isEmpty ? 'Pet sem nome' : _nomeController.text,
        descricao: _descricaoController.text,
        localizacao: _localizacaoController.text,
        imagemUrl: _imagemSelecionada!.path, // Salva o caminho temporário do PC/Web
        status: _statusSelecionado,
      );

      // 2. ADICIONA NA SUA LISTA SIMULADA (banco de dados temporário)
      // Importe o dados_simulados.dart lá no topo do arquivo se der erro!
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

      // Limpa a tela para um novo cadastro
      _formKey.currentState!.reset();
      setState(() {
        _statusSelecionado = StatusPet.PERDIDO;
        _imagemSelecionada = null;
        _nomeController.clear();
        _racaController.clear();
        _telefoneController.clear();
        _localizacaoController.clear();
        _descricaoController.clear();
      });
    }
  }

  // Essa é a mágica que resolve o problema. 
  // Sem placeholder estático. Só exibe se você realmente escolher algo.
  DecorationImage? _obterImagemDeFundo() {
    if (_imagemSelecionada != null) {
      if (kIsWeb) {
        // No Edge/Web, o Flutter usa o caminho do arquivo gerado pelo navegador
        return DecorationImage(
          image: NetworkImage(_imagemSelecionada!.path),
          fit: BoxFit.cover,
        );
      } else {
        // No Celular, ele lê o arquivo físico mesmo
        return DecorationImage(
          image: FileImage(File(_imagemSelecionada!.path)),
          fit: BoxFit.cover,
        );
      }
    }
    // Se ainda não escolheu nenhuma foto do PC, retorna nulo para não crashar
    return null; 
  }

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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Área da Foto de Perfil
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
                        // Chama a função que exibe a SUA foto (se existir)
                        image: _obterImagemDeFundo(), 
                      ),
                      // Mostra o ícone de pata SÓ se você ainda não escolheu uma foto
                      child: _imagemSelecionada == null
                          ? const Icon(Icons.pets, size: 80, color: Cores.iconesOpacos)
                          : null,
                    ),
                    Positioned(
                      bottom: 5,
                      right: 15,
                      child: GestureDetector(
                        onTap: _escolherImagem, // Abre suas pastas do PC
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
                children: [
                  Expanded(
                    child: BotaoStatus(
                      texto: 'Perdido',
                      corAtiva: Cores.vermehoPerdido,
                      isSelected: _statusSelecionado == StatusPet.PERDIDO,
                      onTap: () => setState(() => _statusSelecionado = StatusPet.PERDIDO),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BotaoStatus(
                      texto: 'Encontrado',
                      corAtiva: Cores.verdeEncontrado,
                      isSelected: _statusSelecionado == StatusPet.ENCONTRADO,
                      onTap: () => setState(() => _statusSelecionado = StatusPet.ENCONTRADO),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CampoFormulario(
                      hint: 'Nome do pet (Opcional)',
                      controller: _nomeController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CampoFormulario(
                      hint: 'Raça do pet',
                      controller: _racaController,
                      validator: (value) => value!.isEmpty ? 'Informe a raça' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CampoFormulario(
                hint: 'Digite um número de telefone para contato',
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Informe um telefone' : null,
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
                  onPressed: _salvarCadastro, // Valida tudo e simula envio
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