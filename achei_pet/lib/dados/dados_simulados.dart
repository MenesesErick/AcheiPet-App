import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/models/usuario.dart'; // Certifique-se que o model Usuario existe

// --- SIMULAÇÃO DE SESSÃO ---
// Este é o ID do usuário que está usando o app no momento.
// No Firebase, isso seria FirebaseAuth.instance.currentUser!.uid
String usuarioLogadoId = 'user_demo_1'; 

// --- DADOS SIMULADOS DE USUÁRIOS ---
final List<Usuario> usuariosMock = [
  Usuario(
    id: 'user_demo_1',
    nome: 'Erick Meneses',
    email: 'erick@unitins.br',
    telefonePessoal: '(63) 98888-7777',
    fotoUrl: 'assets/imagens/gatoro.jpg', // Usando uma imagem que já existe para não dar 404
  ),
  Usuario(
    id: 'user_demo_2',
    nome: 'Hugo Valuar',
    email: 'hugo@unitins.br',
    telefonePessoal: '(63) 99999-5555',
    fotoUrl: null, // Testando um usuário sem foto
  ),
];

// --- DADOS SIMULADOS DE PETS ---
final List<Pet> petsMock = [
  Pet(
    id: '1',
    usuarioId: 'user_demo_1', // Erick postou esse anúncio
    nome: 'Mugiwara No Dog',
    descricao: 'Está sempre com um chapéu de palha e quer ser rei',
    localizacao: 'Próx. à Praça dos Girassóis',
    imagemUrl: 'assets/imagens/mugiwara_no_dog.jpg',
    status: StatusPet.ENCONTRADO,
    raca: "King of Pirates",
    nomeDono: "Monkey D. Dragon",
    telefoneContato: "(63) 99999-1111", 
  ),
  Pet(
    id: '2',
    usuarioId: 'user_demo_2', // Hugo postou esse anúncio
    nome: 'Gatoro',
    descricao: 'Tem pelo verde e carrega 3 palitos de dente',
    localizacao: 'Taquaralto, Palmas - TO',
    imagemUrl: 'assets/imagens/gatoro.jpg',
    status: StatusPet.PERDIDO,
    raca: "Musgo",
    nomeDono: "Tony Tony Chopper",
    telefoneContato: "(63) 98888-2222", 
  ),
];