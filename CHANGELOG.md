# Changelog

Todas as mudanças relevantes do SaúdeJá ficam registradas aqui.

O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/)
e as versões seguem o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [1.0.0] - 2026-11-25

### Adicionado

- Design system como pacote separado (`packages/saude_ja_design_system`),
  com app de exemplo e testes visuais próprios.
- Tema escuro, seguindo o sistema ou escolhido no Perfil.
- "Esqueci minha senha": pedido de código por e-mail e troca de senha
  (`POST /auth/forgot-password` e `POST /auth/reset-password`).
- Acessibilidade: descrições para leitores de tela, testes das diretrizes
  de contraste, área de toque e rótulos, e telas que se adaptam a fonte
  aumentada.
- Licença MIT e este CHANGELOG.
- Protótipo das telas no repositório (`docs/prototipo/`), em HTML e imagem.
- Guia de entrega e apresentação (`docs/ENTREGA.md`).

### Alterado

- Cores do tema claro ajustadas para contraste mínimo de 4,5:1: verde
  principal `#137E66`, texto secundário `#5F706A` e erro `#C0392B`.
- `AppColors` e `AppTypography` passam a ficar no tema do Flutter
  (`context.colors`, `context.typography`), com versão clara e escura.
- Nota dos médicos com vírgula (4,9) e textos do Flutter em português.
- `DateChip`, `TimeSlotButton` e `AppButton` crescem com a fonte do
  aparelho em vez de ter tamanho fixo.
- Testes visuais comparam cada componente nos dois temas.

## [0.3.0] - 2026-11-25

### Adicionado

- `HttpApiService`: a mesma API pela rede, escolhida com
  `--dart-define=API=http`.
- Tela de detalhes do médico.
- Remarcar consulta (`PATCH /appointments/{id}/reschedule`).
- Máscara de telefone no Cadastro e telefone formatado no Perfil.
- Carregamento animado (skeleton), parado quando o aparelho pede menos
  animações.
- Sessão salva no aparelho e `GET /users/me`.
- Nome, ícone e tela de abertura próprios.
- GitHub Actions: formatação, análise, testes, cobertura mínima de 85%,
  build web e testes visuais.

### Alterado

- Regras de análise mais rígidas (tipagem estrita, futures, imports).
- Componentes usam apenas tokens (`AppColors`, `AppTypography`,
  `AppSpacing`, `AppRadius`), sem valores soltos.

## [0.2.0] - 2026-11-24

### Adicionado

- Documentação da API (`docs/API.md`) e mock do backend, também como
  servidor HTTP (`tool/mock_server.dart`).
- Telas de Login e Cadastro com ViewModels (`provider`).
- Home com busca, especialidades, próxima consulta e médicos em destaque.
- Agendamento de consultas.
- Abas Consultas (com cancelamento) e Histórico.
- Suporte a web.
- Sample App com todos os componentes e README com prints.

### Corrigido

- `pubspec.lock` alinhado ao SDK do Flutter usado no editor.
- Nomes da tipografia do Sample App em português.

## [0.1.0] - 2026-11-23

### Adicionado

- Estrutura inicial do projeto em MVVM.
- Tokens de cores, tipografia e espaçamentos, tema e componentes básicos
  (`AppButton`, `AppTextField`, `AppCard`, `SpecialtyCard`, `DoctorCard`,
  `AppointmentCard`) com Sample App.

[1.0.0]: https://github.com/GUIZINLT/saude_ja/compare/52024fb...HEAD
[0.3.0]: https://github.com/GUIZINLT/saude_ja/compare/af4cd19...52024fb
[0.2.0]: https://github.com/GUIZINLT/saude_ja/compare/1d01217...af4cd19
[0.1.0]: https://github.com/GUIZINLT/saude_ja/commit/1d01217
