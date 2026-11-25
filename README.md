# SaúdeJá

[![CI](https://github.com/GUIZINLT/saude_ja/actions/workflows/ci.yml/badge.svg)](https://github.com/GUIZINLT/saude_ja/actions/workflows/ci.yml)

<img src="assets/brand/icon.png" width="96" align="right" alt="Ícone do SaúdeJá">

Aplicativo Flutter de **agendamento de consultas médicas**. O paciente cria a conta, encontra médicos por nome ou especialidade, escolhe data e horário, acompanha as consultas e pode remarcá-las ou cancelá-las.

O projeto tem **design system próprio** (tokens, componentes e Sample App), **arquitetura MVVM** com `provider` e um **mock do backend** que segue a [documentação da API](docs/API.md). Assim, todas as telas funcionam sem servidor.

## Telas

| Login | Cadastro | Home |
|:---:|:---:|:---:|
| <img src="docs/screenshots/01_login.png" width="240"> | <img src="docs/screenshots/02_cadastro.png" width="240"> | <img src="docs/screenshots/03_home.png" width="240"> |
| **Busca por especialidade** | **Detalhes do médico** | **Agendamento** |
| <img src="docs/screenshots/04_busca.png" width="240"> | <img src="docs/screenshots/11_medico.png" width="240"> | <img src="docs/screenshots/05_agendamento.png" width="240"> |
| **Consultas** | **Histórico** | **Perfil** |
| <img src="docs/screenshots/06_consultas.png" width="240"> | <img src="docs/screenshots/07_historico.png" width="240"> | <img src="docs/screenshots/08_perfil.png" width="240"> |

## Funcionalidades

- **Login e cadastro**, com validação dos campos, máscara de telefone e mensagens de erro da API (e-mail já cadastrado, senha incorreta).
- **Home**: saudação, busca de médico ou especialidade, especialidades, próxima consulta e médicos em destaque.
- **Detalhes do médico**: CRM, nota, avaliações, dias de atendimento e próximo horário livre.
- **Agendamento**: próximos dias de atendimento do médico e horários livres, ocupados ou bloqueados. Se o horário for ocupado antes da confirmação, a grade se atualiza.
- **Consultas**: consultas confirmadas, com **remarcar** (troca data e horário numa operação só) e cancelar (após confirmação).
- **Histórico**: consultas realizadas e canceladas.
- **Perfil**: dados do paciente e saída da conta.
- **Sessão salva**: ao reabrir o app (ou recarregar a página na web), o paciente continua logado.
- **Carregamento animado** (skeleton) no formato do conteúdo; fica parado se o aparelho pedir menos animações.
- **Ícone e tela de abertura** próprios, gerados a partir do design system.
- Roda em **Android, iOS e web**.

## Arquitetura (MVVM)

```
View (tela)  ──lê estado / chama ações──▶  ViewModel (ChangeNotifier)
                                                │
                                                ▼
                                           Repository
                                                │
                                                ▼
                                ApiService (interface)
                                                │
                                 JsonApiService (rotas e JSON)
                                                │
                                   ┌────────────┴────────────┐
                                   ▼                         ▼
                           MockApiService             HttpApiService
                           backend simulado           pela rede (HTTP),
                           na memória                 qualquer servidor
                                                      que siga docs/API.md
```

- **Views** só desenham e repassam ações; não validam nem chamam a API.
- **ViewModels** guardam o estado da tela (carregando, erro, dados) e as regras de apresentação.
- **Repositories** reúnem as chamadas por assunto (autenticação, catálogo, consultas).
- **ApiService** é o contrato da API. O `JsonApiService` implementa as rotas uma vez só; o `MockApiService` e o `HttpApiService` mudam apenas como a requisição é enviada. A escolha é feita na hora de rodar (veja abaixo).

```
lib/
├── core/              rotas, tema, validações e formatação de datas
├── data/
│   ├── models/        User, Doctor, Specialty, Appointment, ...
│   ├── repositories/  AuthRepository, CatalogRepository, AppointmentRepository
│   └── services/      ApiService (interface), MockApiService e MockBackend
├── design_system/
│   ├── tokens/        AppColors, AppTypography, AppSpacing
│   ├── components/    componentes reutilizáveis (lista abaixo)
│   └── sample_app/    vitrine dos componentes
├── features/
│   ├── auth/          Login e Cadastro
│   ├── home/          Home e menu inferior
│   ├── appointments/  Agendamento e Consultas
│   ├── history/       Histórico
│   └── profile/       Perfil
├── main.dart                 app
└── main_design_system.dart   abre direto o Sample App
```

## Design system

Cores, tipografia, espaçamentos e arredondamentos ficam centralizados em `lib/design_system/tokens/` (`AppColors`, `AppTypography`, `AppSpacing` e `AppRadius`). Os componentes não usam valores soltos: toda cor, tamanho de fonte, espaço e canto vem de um token.

| Componente | Uso |
|---|---|
| `AppButton` | Botão principal e secundário, com estado de carregando |
| `AppTextField` | Campo de formulário com ícone, erro e ação no fim |
| `AppCard` | Card base |
| `SpecialtyCard` | Especialidade com ícone |
| `DoctorCard` | Médico com especialidade e nota |
| `AppointmentCard` | Consulta com data, status e ação opcional |
| `DateChip` | Dia no seletor de datas |
| `TimeSlotButton` | Horário livre, ocupado ou escolhido |
| `AppDialog` | Aviso e confirmação (inclusive de ação destrutiva) |
| `AppBottomNavigation` | Menu inferior |

O **Sample App** (`flutter run -t lib/main_design_system.dart`) mostra os tokens e todos os componentes, cada um nos seus estados. Dá para escolher dia e horário e abrir os diálogos.

<details>
<summary>Ver o Sample App inteiro</summary>

<img src="docs/screenshots/10_design_system_completo.png" width="320">

</details>

## API e mock do backend

- A documentação completa, com rotas, requests, responses e códigos de status, está em **[docs/API.md](docs/API.md)**.
- Os dados iniciais ficam em `assets/mock/*.json`. Agendar e cancelar funcionam durante o uso, e tudo volta ao estado inicial quando o app reinicia.
- O mesmo mock pode rodar como **servidor HTTP** (`http://localhost:8080`):

```powershell
dart run tool/mock_server.dart
```

- Com o servidor rodando, o app pode usá-lo **pela rede** em vez do mock interno:

```powershell
flutter run -d chrome --dart-define=API=http
```

No emulador Android, o computador fica em `10.0.2.2`:

```powershell
flutter run --dart-define=API=http --dart-define=API_URL=http://10.0.2.2:8080
```

**Usuário de teste:** `maria@saudeja.com` / `123456`

## Como rodar

Pré-requisito: Flutter (Dart 3.12 ou superior).

```powershell
flutter pub get
```

```powershell
flutter run
```

No navegador:

```powershell
flutter run -d chrome
```

Só o Sample App do design system:

```powershell
flutter run -t lib/main_design_system.dart
```

## Testes

```powershell
flutter analyze
```

```powershell
flutter test
```

São 90 testes, com **cobertura de 92%**:

- **Regras do mock** e da API HTTP (requisições, erros, falta de rede).
- **ViewModels**: login, cadastro, sessão salva, Home, detalhes do médico, agendamento, remarcação, consultas e histórico.
- **Fluxos completos nas telas**: do login até agendar, remarcar e cancelar.
- **Testes visuais** dos componentes do design system: cada componente é comparado com uma imagem de referência em `test/golden/goldens/`. Depois de mudar um componente de propósito:

```powershell
flutter test test/golden --update-goldens
```

Para ver a cobertura por pasta:

```powershell
flutter test --coverage
```

```powershell
dart run tool/coverage_summary.dart
```

A análise estática usa regras mais rígidas que o padrão do Flutter (tipagem estrita, `const`, aspas simples, ordem de imports, futures não aguardados), definidas em [analysis_options.yaml](analysis_options.yaml).

A cada push, o **GitHub Actions** ([.github/workflows/ci.yml](.github/workflows/ci.yml)) confere formatação, análise estática, testes, cobertura mínima de 85% e o build web (no Linux) e roda os testes visuais num Windows, o mesmo sistema em que as imagens de referência foram geradas. O selo no topo deste README mostra o resultado, e a tabela de cobertura aparece no resumo de cada execução.

Os prints deste README são gerados por teste, sempre com os mesmos dados e data. Para atualizar depois de mudar alguma tela:

```powershell
flutter test screenshots/screenshots_test.dart --update-goldens
```

O ícone e a tela de abertura também são gerados a partir do design system
(imagens em `assets/brand/`):

```powershell
flutter test screenshots/brand_assets_test.dart --update-goldens
```

```powershell
dart run flutter_launcher_icons
```

```powershell
dart run flutter_native_splash:create
```

## Tecnologias

- Flutter e Dart
- `provider` (ChangeNotifier) para MVVM
- `shared_preferences` para salvar a sessão
- `http` para a API pela rede
- `flutter_launcher_icons` e `flutter_native_splash` para ícone e tela de abertura
- GitHub Actions para integração contínua
- Material 3
