# Guia de entrega e apresentação

Este guia reúne, num lugar só, onde está cada item pedido no trabalho e um
roteiro para apresentar o app.

## 1. Onde está cada item do enunciado

| O que foi pedido | Onde está |
|---|---|
| Definir o tema do app | Identidade verde e branco, fonte Roboto. Tema claro e escuro em [`AppTheme`](../packages/saude_ja_design_system/lib/src/theme/app_theme.dart), montado a partir dos tokens |
| Prototipar as telas | [`docs/prototipo/`](prototipo): Login, Cadastro, Home, Especialidades e Agendamento (HTML e imagem) |
| Conjunto de componentes do design system | [`packages/saude_ja_design_system`](../packages/saude_ja_design_system): tokens (cores, tipografia, espaçamentos, arredondamentos) e 11 componentes |
| Sample App do design system | [`sample_app.dart`](../packages/saude_ja_design_system/lib/src/sample_app/sample_app.dart). Roda com `flutter run -t lib/main_design_system.dart` |
| Documentação da API (requests e responses) | [`docs/API.md`](API.md): 13 rotas, cada uma com request, response, códigos de status e erros |
| Mock do backend | [`lib/data/services/mock/mock_backend.dart`](../lib/data/services/mock/mock_backend.dart), com os dados em [`assets/mock/`](../assets/mock). Também roda como servidor HTTP: `dart run tool/mock_server.dart` |
| Telas no padrão de projeto especificado (MVVM) | [`lib/features/`](../lib/features): cada tela tem View (desenho) e ViewModel (estado e regras), que usam os Repositories |
| Commit e push | Histórico no GitHub, um commit por etapa (resumo no [CHANGELOG](../CHANGELOG.md)) |

Além do pedido: testes automatizados (120), integração contínua no GitHub
Actions, tema escuro, acessibilidade, sessão salva, API pela rede
(`HttpApiService`), ícone e tela de abertura próprios.

## 2. Antes de apresentar

```powershell
cd C:\Users\leaot\saude_ja\saude_ja
```

```powershell
flutter pub get
```

```powershell
flutter run -d chrome
```

- Usuário de teste: `maria@saudeja.com` / `123456`.
- Os dados voltam ao estado inicial ao reiniciar o app (`R` no terminal).
  Se a Maria já entrou antes, o app abre direto na Home; use **Perfil ›
  Sair** para começar pelo Login.
- Deixe aberto também o [README no GitHub](https://github.com/GUIZINLT/saude_ja),
  com o selo do CI verde e os prints.

## 3. Roteiro de demonstração (cerca de 7 minutos)

1. **Protótipo (30 s).** Mostre `docs/prototipo` no README: "Antes do
   código, prototipamos as telas principais com a identidade do app."
2. **Design system (1 min).** Rode o Sample App ou mostre o print completo
   no README. "Tokens de cor, tipografia e espaçamento e 11 componentes.
   É um pacote separado: o app só importa
   `saude_ja_design_system.dart`."
3. **Login (30 s).** Clique em Entrar vazio (erros nos campos), depois
   senha errada ("E-mail ou senha incorretos.", que vem da API), depois
   entre como Maria.
4. **Home (1 min).** Saudação, busca ("cardio"), toque numa especialidade,
   próxima consulta e médicos em destaque.
5. **Agendar (1 min).** Dra. Helena › detalhes do médico › Agendar
   consulta. Mostre o horário bloqueado (riscado), escolha um horário,
   confirme. A Home atualiza a próxima consulta.
6. **Consultas e Histórico (1 min).** Remarque a consulta para outro dia;
   cancele outra (pede confirmação). Mostre que ela foi para o Histórico.
7. **Perfil (30 s).** Troque para o tema escuro.
8. **Esqueci minha senha (30 s).** Saia, peça o código, troque a senha e
   entre com a nova.
9. **Bastidores (1 min).** Mostre `docs/API.md` (uma rota completa) e a
   aba Actions do GitHub (CI verde a cada push).
