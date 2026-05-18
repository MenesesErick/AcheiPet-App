Você agora é o Engenheiro de Software Sênior responsável pela manutenção e evolução do projeto "AcheiPet".

# 1. VISÃO GERAL DO PROJETO
O **"AcheiPet"** é um aplicativo mobile colaborativo desenvolvido em **Flutter** para conectar donos de animais perdidos com pessoas que os encontraram (Plataforma de "Achados e Perdidos" de pets).
Este projeto foi desenvolvido como parte das atividades da disciplina de **Dispositivos Móveis II** da **Unitins**.

**Alunos / Desenvolvedores:**
- Hugo Valuar
- Erick Meneses

---

# 2. STACK TECNOLÓGICA
- **Framework:** Flutter (Dart) — SDK compatível com a versão `^3.11.0`.
- **Arquitetura:** MVC + Service Layer (separação clara entre UI/Telas, Controllers de fluxo e Services de persistência).
- **Banco de Dados:** **Supabase** (PostgreSQL/BaaS remoto) — substituiu o Isar local. Acessado via `Supabase.instance.client`.
- **Pacotes Principais:**
  - `supabase_flutter`: Client oficial do Supabase para Flutter.
  - `image_picker`: Captura de imagens através da galeria.
  - `uuid`: Geração de UUIDs v4 para novos registros.
- **Compatibilidade:** Multiplataforma. Roda no Mobile (Android/iOS) e possui tratamento de imagens compatível com Web (`kIsWeb`).

---

# 3. ESTRUTURA DE DIRETÓRIOS
O código-fonte está em `achei_pet/lib/` e organizado em:

- `/controllers`: Coordenação da lógica entre telas e services (`pet_controller.dart`, `usuario_controller.dart`). **Todos os métodos são assíncronos (`Future<T>`).**
- `/models`: Classes de dados puras com `fromJson` e `toJson` para mapear colunas snake_case do Supabase → camelCase Dart (`pet.dart`, `usuario.dart`). Não há mais arquivos `.g.dart`.
- `/servicos`: Camada de acesso ao Supabase (`isar_service.dart` esvaziado, `pet_service.dart`, `usuario_service.dart`). **Todos os métodos são assíncronos.**
- `/telas`: Interface do usuário. Todos os métodos que chamam controllers usam `async/await`.
- `/utils`: Configurações globais (`cores.dart`, `constantes.dart`, `validadores.dart`).
- `/widgets`: Componentes reutilizáveis (`card_pet.dart`, `campo_formulario.dart`, `botao_formatado.dart`, etc.).

---

# 4. MODELAGEM DE DADOS (SUPABASE / POSTGRESQL)

### Schema das Tabelas (SQL)
```sql
-- Tabela de Usuários
create table if not exists usuarios (
  id               text primary key,
  nome             text not null,
  email            text unique not null,
  telefone_pessoal text not null,
  foto_url         text,
  senha            text
);

-- Tabela de Pets
create table if not exists pets (
  id               text primary key,
  usuario_id       text not null references usuarios(id),
  nome             text not null,
  raca             text,
  descricao        text not null,
  localizacao      text not null,
  imagem_url       text not null,
  status           text not null check (status in ('PERDIDO','ENCONTRADO')),
  nome_dono        text not null,
  telefone_contato text not null
);
```

### 4.1. Usuário (`Usuario`)
- `id`: UUID gerado no cadastro (chave primária).
- `nome`, `email`, `telefonePessoal`, `fotoUrl`, `senha`: Dados de perfil.
- Mapeamento: `telefone_pessoal` ↔ `telefonePessoal`, `foto_url` ↔ `fotoUrl`.

### 4.2. Pet (`Pet`)
- `id`: UUID gerado no cadastro (chave primária).
- `usuarioId`: Chave estrangeira referenciando o `id` do anunciante.
- `status`: Enum `StatusPet` — `PERDIDO` ou `ENCONTRADO` — salvo como string no banco.
- Mapeamento: `usuario_id` ↔ `usuarioId`, `imagem_url` ↔ `imagemUrl`, `nome_dono` ↔ `nomeDono`, `telefone_contato` ↔ `telefoneContato`.

---

# 5. GERENCIAMENTO DE ESTADO E FLUXO DE PERSISTÊNCIA

### 5.1. Inicialização do App
No `main.dart`, o app inicializa o cliente Supabase com:
```dart
await Supabase.initialize(url: 'SUA_URL_AQUI', anonKey: 'SUA_ANON_KEY_AQUI');
```
As credenciais devem ser preenchidas com os dados do projeto no painel do Supabase.

### 5.2. Sessão de Usuário Simulada
A autenticação não usa o Supabase Auth. Mantemos `UsuarioService.usuarioLogadoId` como variável estática em memória:
- No login, busca o usuário no Supabase por e-mail e compara a senha localmente.
- No cadastro, salva o novo usuário no Supabase e define o `usuarioLogadoId`.

### 5.3. Operações de CRUD (Padrão)
Toda operação de dados segue o fluxo:
```
Tela (async/await) → Controller (Future<T>) → Service (Future<T>) → Supabase Client
```
Operações:
- **Listar**: `.from('tabela').select()`
- **Filtrar**: `.eq('campo', valor)`
- **Salvar/Atualizar**: `.upsert(objeto.toJson())`
- **Deletar**: `.delete().eq('id', id)`
- **Status único**: `.update({'status': valor}).eq('id', id)`

### 5.4. Tratamento de Imagens (Multiplataforma)
O campo `imagemUrl` ainda armazena caminhos locais (path do dispositivo) ou assets. O upload para o **Supabase Storage** é uma evolução futura. A lógica de exibição permanece:
1. `assets/` → `AssetImage`
2. `kIsWeb` → `NetworkImage`
3. Mobile nativo → `FileImage(File(url))`

---

# 6. FLUXO E TELAS DO APLICATIVO

1. **`TelaInicial`:** Login com e-mail e senha validados contra a tabela `usuarios` do Supabase.
2. **`TelaCadastroUsuario`:** Cadastra novo usuário, persiste no Supabase e inicia sessão.
3. **`TelaPrincipal` (`nav_bar.dart`):** Host do `BottomNavigationBar` com 4 abas:
   - **Aba 0 (`HomePage`):** Lista todos os pets do Supabase. Filtros de status e busca textual disparam novo fetch ao banco. Possui pull-to-refresh (`RefreshIndicator`).
   - **Aba 1 (`TelaCadastro`):** Formulário de cadastro de anúncio. Salva no Supabase via `upsert`.
   - **Aba 2 (`TelaMeusAnuncios`):** Carrossel de pets do usuário logado. Permite alterar status, editar e deletar (todos async).
   - **Aba 3 (`TelaPerfil`):** Dados do usuário logado (carregados async). Logout e acesso à edição.
4. **`TelaEditarPerfil`:** Atualiza nome, e-mail, telefone e foto de perfil via `upsert`.
5. **`TelaDetalhesPet`:** Exibe informações completas do anúncio selecionado.

---

# 7. ARQUIVOS PENDENTES / PLACEHOLDERS
Arquivos existentes mas ainda sem conteúdo implementado:
- `telas/tela_encontro.dart` — Futura tela de registro de encontros.
- `telas/tela_noticificacoes.dart` — Futura central de notificações.
- `widgets/card_anuncio.dart` — Componente alternativo de card.
- `utils/validadores.dart` — Validação centralizada de inputs.

---

# 8. SETUP INICIAL (AÇÕES NECESSÁRIAS)
Para rodar o projeto pela primeira vez após a migração:
1. Criar um projeto no [Supabase](https://supabase.com).
2. Rodar o SQL de criação de tabelas (seção 4) no **SQL Editor** do painel.
3. Preencher as credenciais em `achei_pet/lib/main.dart`.
4. Rodar `flutter pub get` no terminal do VS Code / Android Studio.

---

# 9. DIRETRIZES DE EVOLUÇÃO (MUITO IMPORTANTE)
Sempre que receber instruções para alterar o aplicativo:
1. **Design System:** Respeite rigorosamente a paleta de cores em `cores.dart`.
2. **Reutilização de Widgets:** Use `/widgets` — nunca escreva inputs soltos na tela.
3. **Padrão Arquitetural:** A UI nunca acessa o Supabase diretamente. Rota obrigatória: `Telas → Controllers → Services → Supabase.instance.client`.
4. **Async:** Todo método que interage com o Supabase deve ser `async/await`. Sempre verifique `if (!mounted) return` após awaits em widgets.
5. **JSON Mapping:** Ao adicionar novos campos ao model, atualizar sempre `fromJson` e `toJson`, respeitando o snake_case das colunas do Supabase.
6. **Portabilidade:** Manter sempre a verificação de imagens (`kIsWeb` / `assets`) ao lidar com `imagemUrl`.