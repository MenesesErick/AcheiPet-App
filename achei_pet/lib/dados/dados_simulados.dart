import 'package:achei_pet/models/pet.dart';

final List<Pet> petsMock = [
  Pet(
    id: '1',
    nome: 'Mugiwara No Dog',
    descricao: 'Está sempre com um chapéu de palha e quer ser rei',
    localizacao: 'Próx. à Praça dos Girassóis',
    imagemUrl: 'assets/imagens/mugiwara_no_dog.jpg',
    status: StatusPet.ENCONTRADO,
  ),
  Pet(
    id: '2',
    nome: 'Gatoro',
    descricao: 'Tem pelo verde e carrega 3 palitos de dente',
    localizacao: 'Taquaralto, Palmas - TO',
    imagemUrl:
        'assets/imagens/gatoro.jpg',
    status: StatusPet.PERDIDO,
  ),
];
