# SaúdeJá: documentação da API

API REST do app SaúdeJá (agendamento de consultas). Esta documentação descreve o contrato entre o app Flutter e o backend. Enquanto o backend real não existe, o mesmo contrato é atendido pelo **mock** (ver [Mock do backend](#mock-do-backend)).

| Item | Valor |
|---|---|
| URL base (mock HTTP) | `http://localhost:8080` |
| Formato | JSON, UTF-8 (`Content-Type: application/json`) |
| Autenticação | `Authorization: Bearer <token>`, obtido em `/auth/login` ou `/auth/register` |
| Datas | `AAAA-MM-DD` (ex.: `2026-11-26`) |
| Horários | `HH:mm`, 24 h (ex.: `09:30`) |
| Data e hora completas | ISO 8601 (ex.: `2026-11-20T14:12:00-03:00`) |

## Sumário

| Método | Rota | Login | Tela que usa |
|---|---|---|---|
| POST | [`/auth/login`](#post-authlogin) | não | Login |
| POST | [`/auth/register`](#post-authregister) | não | Cadastro |
| GET | [`/users/me`](#get-usersme) | **sim** | Abertura do app (restaurar a sessão salva) |
| GET | [`/specialties`](#get-specialties) | não | Home, Especialidades |
| GET | [`/doctors`](#get-doctors) | não | Home (médicos em destaque), lista de médicos, busca |
| GET | [`/doctors/{id}`](#get-doctorsid) | não | Agendamento (cabeçalho) |
| GET | [`/doctors/{id}/availability`](#get-doctorsidavailability) | não | Agendamento (datas e horários) |
| POST | [`/appointments`](#post-appointments) | **sim** | Agendamento (Confirmar agendamento) |
| GET | [`/appointments`](#get-appointments) | **sim** | Home (próxima consulta), Consultas, Histórico |
| PATCH | [`/appointments/{id}/cancel`](#patch-appointmentsidcancel) | **sim** | Consultas |
| PATCH | [`/appointments/{id}/reschedule`](#patch-appointmentsidreschedule) | **sim** | Consultas (Remarcar) |

## Erros

Toda resposta de erro tem o mesmo formato:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Verifique os campos informados.",
    "fields": {
      "email": "E-mail inválido."
    }
  }
}
```

- `code`: identificador fixo, para o app decidir o que fazer.
- `message`: texto em português, pronto para mostrar ao usuário.
- `fields`: só em erros de validação (`422`). A chave é o nome do campo do formulário.

| Status | Quando acontece |
|---|---|
| `200 OK` | Sucesso |
| `201 Created` | Recurso criado (cadastro, agendamento) |
| `400 Bad Request` | Corpo não é JSON (`INVALID_JSON`, `INVALID_BODY`) ou parâmetro de URL inválido (`INVALID_PARAMETER`) |
| `401 Unauthorized` | Login inválido (`INVALID_CREDENTIALS`) ou token ausente ou inválido (`UNAUTHORIZED`) |
| `404 Not Found` | Médico, consulta ou rota não existe |
| `409 Conflict` | Conflito com o estado atual: e-mail já cadastrado, horário ocupado, consulta já cancelada |
| `422 Unprocessable Entity` | Campos do corpo inválidos (`VALIDATION_ERROR`, `DATE_IN_PAST`) |

---

## Autenticação

### POST /auth/login

Entra com e-mail e senha. O e-mail não diferencia maiúsculas de minúsculas.

**Request**

```json
{
  "email": "maria@saudeja.com",
  "password": "123456"
}
```

| Campo | Tipo | Obrigatório |
|---|---|---|
| `email` | string | sim |
| `password` | string | sim |

**Response `200 OK`**

```json
{
  "token": "mock-u1-1",
  "user": {
    "id": "u1",
    "name": "Maria Souza",
    "email": "maria@saudeja.com",
    "phone": "63999990000",
    "createdAt": "2026-11-01T10:00:00-03:00"
  }
}
```

**Erros**

| Status | `code` | Quando |
|---|---|---|
| 422 | `VALIDATION_ERROR` | e-mail ou senha vazios (`fields.email`, `fields.password`) |
| 401 | `INVALID_CREDENTIALS` | e-mail ou senha incorretos |

### POST /auth/register

Cria a conta do paciente e já devolve a sessão, então o app vai direto para a Home.

> O campo **Confirmar senha** da tela é validado só no app (ViewModel) e não é enviado.

**Request**

```json
{
  "name": "João Silva",
  "email": "joao@email.com",
  "phone": "(63) 98888-7777",
  "password": "segredo1",
  "acceptedTerms": true
}
```

| Campo | Tipo | Regra |
|---|---|---|
| `name` | string | mínimo 3 caracteres |
| `email` | string | e-mail válido e ainda não cadastrado |
| `phone` | string | DDD + número, 10 ou 11 dígitos. Pontuação é aceita e removida |
| `password` | string | mínimo 6 caracteres |
| `acceptedTerms` | boolean | precisa ser `true` |

**Response `201 Created`**: mesmo formato do login.

```json
{
  "token": "mock-u2-2",
  "user": {
    "id": "u2",
    "name": "João Silva",
    "email": "joao@email.com",
    "phone": "63988887777",
    "createdAt": "2026-11-24T15:20:00.000"
  }
}
```

**Erros**

| Status | `code` | Quando |
|---|---|---|
| 422 | `VALIDATION_ERROR` | um ou mais campos inválidos; `fields` traz cada um |
| 409 | `EMAIL_ALREADY_IN_USE` | já existe conta com o e-mail |

Exemplo de `422`:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Verifique os campos informados.",
    "fields": {
      "password": "A senha deve ter pelo menos 6 caracteres.",
      "acceptedTerms": "É preciso aceitar os termos de uso."
    }
  }
}
```

### GET /users/me

Devolve o usuário dono do token. O app chama esta rota ao abrir, quando há um token salvo no aparelho: se ela responder `200`, o usuário entra direto na Home; se responder `401`, o app apaga o token e mostra o Login.

**Header:** `Authorization: Bearer <token>`

**Response `200 OK`**

```json
{
  "id": "u1",
  "name": "Maria Souza",
  "email": "maria@saudeja.com",
  "phone": "63999990000",
  "createdAt": "2026-11-01T10:00:00-03:00"
}
```

**Erros**

| Status | `code` | Quando |
|---|---|---|
| 401 | `UNAUTHORIZED` | token ausente, inválido ou de um usuário que não existe mais |

> **Token no mock:** o formato é `mock-<idDoUsuario>-<n>`. Como num JWT, o próprio token diz de quem é, então ele continua valendo depois de reiniciar o app, desde que o usuário exista nos dados do mock. Usuários criados pelo cadastro somem quando o app reinicia, e o token deles passa a responder `401`.

---

## Especialidades e médicos

### GET /specialties

Lista as especialidades.

**Response `200 OK`**

```json
[
  { "id": "cardiologia", "name": "Cardiologia", "icon": "favorite", "doctorCount": 2 },
  { "id": "dermatologia", "name": "Dermatologia", "icon": "face", "doctorCount": 1 },
  { "id": "pediatria", "name": "Pediatria", "icon": "child_care", "doctorCount": 1 },
  { "id": "ortopedia", "name": "Ortopedia", "icon": "accessibility_new", "doctorCount": 1 },
  { "id": "neurologia", "name": "Neurologia", "icon": "psychology", "doctorCount": 1 },
  { "id": "oftalmologia", "name": "Oftalmologia", "icon": "visibility", "doctorCount": 1 }
]
```

| Campo | Descrição |
|---|---|
| `icon` | nome de um ícone do Material (`Icons.favorite`, `Icons.face`…). O app converte o nome em `IconData` |
| `doctorCount` | quantos médicos atendem a especialidade |

### GET /doctors

Lista os médicos. Todos os filtros são opcionais e podem ser combinados.

| Query | Exemplo | Efeito |
|---|---|---|
| `specialtyId` | `cardiologia` | só médicos da especialidade |
| `q` | `helena`, `cardio` | busca no nome e na especialidade, sem diferenciar acentos e maiúsculas |
| `featured` | `true` / `false` | médicos em destaque (Home) |

Exemplo: `GET /doctors?featured=true`

**Response `200 OK`**

```json
[
  {
    "id": "d1",
    "name": "Dra. Helena Ribeiro",
    "specialtyId": "cardiologia",
    "specialtyName": "Cardiologia",
    "crm": "CRM/TO 12345",
    "rating": 4.9,
    "reviewCount": 128,
    "bio": "Cardiologista com 12 anos de experiência em prevenção e check-up cardíaco.",
    "photoUrl": null,
    "featured": true
  },
  {
    "id": "d2",
    "name": "Dr. Carlos Mendes",
    "specialtyId": "dermatologia",
    "specialtyName": "Dermatologia",
    "crm": "CRM/TO 23456",
    "rating": 4.8,
    "reviewCount": 96,
    "bio": "Dermatologista clínico, atende acne, manchas e dermatologia geral.",
    "photoUrl": null,
    "featured": true
  }
]
```

Lista vazia (`[]`) quando nada combina com o filtro.

**Erros**

| Status | `code` | Quando |
|---|---|---|
| 400 | `INVALID_PARAMETER` | `featured` diferente de `true`/`false` |

### GET /doctors/{id}

Um médico. Mesmo objeto da lista.

**Response `200 OK`**: objeto `Doctor` (como acima).

**Erros**

| Status | `code` | Quando |
|---|---|---|
| 404 | `DOCTOR_NOT_FOUND` | id não existe |

### GET /doctors/{id}/availability

Dias de atendimento e horários do médico, para a tela de Agendamento. Só aparecem dias em que o médico atende (por exemplo, a Dra. Helena atende de segunda a sexta, então o fim de semana é pulado).

| Query | Padrão | Regra |
|---|---|---|
| `from` | hoje | data inicial, `AAAA-MM-DD` |
| `days` | `5` | quantos dias de atendimento devolver, de 1 a 14 |

Exemplo: `GET /doctors/d1/availability?from=2026-11-24&days=5`

**Response `200 OK`**

```json
{
  "doctorId": "d1",
  "days": [
    {
      "date": "2026-11-24",
      "slots": [
        { "time": "08:00", "available": true },
        { "time": "08:30", "available": false },
        { "time": "09:00", "available": true },
        { "time": "09:30", "available": true },
        { "time": "10:00", "available": true },
        { "time": "10:30", "available": true }
      ]
    },
    { "date": "2026-11-25", "slots": [ "..." ] },
    { "date": "2026-11-26", "slots": [ "..." ] },
    { "date": "2026-11-27", "slots": [ "..." ] },
    { "date": "2026-11-30", "slots": [ "..." ] }
  ]
}
```

Um horário fica `"available": false` quando já passou, está bloqueado na agenda do médico ou já tem consulta confirmada. Na tela, ele aparece cinza e riscado, como no protótipo.

**Erros**

| Status | `code` | Quando |
|---|---|---|
| 404 | `DOCTOR_NOT_FOUND` | id não existe |
| 400 | `INVALID_PARAMETER` | `from` fora do formato ou `days` fora de 1 a 14 |

---

## Consultas (requer login)

Todas as rotas abaixo exigem o header:

```
Authorization: Bearer mock-u1-1
```

Sem ele, ou com token inválido, a resposta é `401` com `code: "UNAUTHORIZED"`. O paciente só enxerga e altera as próprias consultas.

### Objeto `Appointment`

```json
{
  "id": "a1",
  "doctorId": "d1",
  "doctorName": "Dra. Helena Ribeiro",
  "specialtyId": "cardiologia",
  "specialtyName": "Cardiologia",
  "date": "2026-11-26",
  "time": "09:30",
  "status": "confirmed",
  "notes": "Check-up anual",
  "createdAt": "2026-11-20T14:12:00-03:00",
  "cancelledAt": null
}
```

| `status` | Texto no app | Significado |
|---|---|---|
| `confirmed` | Confirmada | agendada, ainda vai acontecer |
| `completed` | Realizada | o horário já passou (o backend muda sozinho de `confirmed` para `completed`) |
| `cancelled` | Cancelada | cancelada pelo paciente; `cancelledAt` traz quando |

### POST /appointments

Agenda uma consulta (botão **Confirmar agendamento**).

**Request**

```json
{
  "doctorId": "d1",
  "date": "2026-11-27",
  "time": "10:00",
  "notes": "Primeira consulta"
}
```

| Campo | Tipo | Obrigatório |
|---|---|---|
| `doctorId` | string | sim |
| `date` | string `AAAA-MM-DD` | sim |
| `time` | string `HH:mm` | sim, precisa ser um horário da agenda do médico |
| `notes` | string | não |

**Response `201 Created`**: objeto `Appointment` com `status: "confirmed"`.

**Erros**

| Status | `code` | Quando |
|---|---|---|
| 422 | `VALIDATION_ERROR` | campo ausente ou fora do formato |
| 422 | `DATE_IN_PAST` | data e hora já passaram |
| 404 | `DOCTOR_NOT_FOUND` | médico não existe |
| 409 | `SLOT_UNAVAILABLE` | horário ocupado, bloqueado ou fora da agenda do médico |
| 409 | `PATIENT_TIME_CONFLICT` | o paciente já tem outra consulta no mesmo dia e horário |
| 401 | `UNAUTHORIZED` | sem login |

### GET /appointments

Consultas do paciente logado.

| Query | Padrão | Efeito |
|---|---|---|
| `status` | todos | um ou mais status separados por vírgula: `confirmed`, `completed`, `cancelled` |
| `order` | `asc` | `asc` = mais antiga primeiro, `desc` = mais recente primeiro |

Uso por tela:

| Tela | Chamada |
|---|---|
| Home, próxima consulta | `GET /appointments?status=confirmed&order=asc` (pegar o primeiro item) |
| Consultas | `GET /appointments?status=confirmed` |
| Histórico | `GET /appointments?status=completed,cancelled&order=desc` |

**Response `200 OK`**: lista de `Appointment`.

```json
[
  {
    "id": "a3",
    "doctorId": "d4",
    "doctorName": "Dr. Rafael Costa",
    "specialtyId": "ortopedia",
    "specialtyName": "Ortopedia",
    "date": "2026-11-17",
    "time": "15:00",
    "status": "cancelled",
    "notes": null,
    "createdAt": "2026-11-05T18:05:00-03:00",
    "cancelledAt": "2026-11-12T08:20:00-03:00"
  },
  {
    "id": "a2",
    "doctorId": "d2",
    "doctorName": "Dr. Carlos Mendes",
    "specialtyId": "dermatologia",
    "specialtyName": "Dermatologia",
    "date": "2026-11-09",
    "time": "14:00",
    "status": "completed",
    "notes": null,
    "createdAt": "2026-11-02T09:40:00-03:00",
    "cancelledAt": null
  }
]
```

**Erros**

| Status | `code` | Quando |
|---|---|---|
| 400 | `INVALID_PARAMETER` | `status` ou `order` com valor desconhecido |
| 401 | `UNAUTHORIZED` | sem login |

### PATCH /appointments/{id}/cancel

Cancela uma consulta confirmada. O horário volta a ficar disponível para outros pacientes. Sem corpo.

**Response `200 OK`**: objeto `Appointment` com `status: "cancelled"` e `cancelledAt` preenchido.

**Erros**

| Status | `code` | Quando |
|---|---|---|
| 404 | `APPOINTMENT_NOT_FOUND` | não existe ou é de outro paciente |
| 409 | `APPOINTMENT_ALREADY_CANCELLED` | já estava cancelada |
| 409 | `APPOINTMENT_COMPLETED` | consulta já realizada |
| 401 | `UNAUTHORIZED` | sem login |

### PATCH /appointments/{id}/reschedule

Troca a data e o horário de uma consulta confirmada, com o mesmo médico. É uma operação só: se o novo horário não estiver livre, a consulta continua como estava (o paciente nunca fica sem consulta, como aconteceria cancelando e agendando de novo). O horário antigo volta a ficar disponível.

**Request**

```json
{
  "date": "2026-11-27",
  "time": "10:00"
}
```

| Campo | Tipo | Obrigatório |
|---|---|---|
| `date` | string `AAAA-MM-DD` | sim |
| `time` | string `HH:mm` | sim, precisa ser um horário da agenda do médico |

**Response `200 OK`**: objeto `Appointment` com a nova `date`/`time` e o mesmo `id`.

**Erros**

| Status | `code` | Quando |
|---|---|---|
| 422 | `VALIDATION_ERROR` | `date` ou `time` fora do formato |
| 422 | `DATE_IN_PAST` | nova data e hora já passaram |
| 404 | `APPOINTMENT_NOT_FOUND` | não existe ou é de outro paciente |
| 409 | `SLOT_UNAVAILABLE` | horário ocupado, bloqueado, fora da agenda ou igual ao atual |
| 409 | `PATIENT_TIME_CONFLICT` | o paciente já tem outra consulta nesse dia e horário |
| 409 | `APPOINTMENT_ALREADY_CANCELLED` | consulta cancelada |
| 409 | `APPOINTMENT_COMPLETED` | consulta já realizada |
| 401 | `UNAUTHORIZED` | sem login |

---

## Mock do backend

O mock segue exatamente este documento: mesmas rotas, campos, regras e códigos de status.

### Arquivos

```
assets/mock/                      dados iniciais (JSON)
  users.json                      pacientes (com senha, que nunca sai na resposta)
  specialties.json
  doctors.json
  schedules.json                  agenda de cada médico: dias da semana, horários e bloqueios
  appointments.json
lib/data/models/                  User, AuthSession, RegisterRequest, Specialty, Doctor,
                                  DoctorAvailability/AvailableDay/TimeSlot, Appointment
lib/data/services/
  api_service.dart                interface (contrato) usada pelos repositórios
  api_exception.dart              erro { statusCode, code, message, fields }
  mock_api_service.dart           implementação para o app: lê os JSONs + Future.delayed
  mock/mock_backend.dart          regras do backend simulado (Dart puro)
tool/mock_server.dart             servidor HTTP opcional com o mesmo mock
test/mock_backend_test.dart       17 testes das rotas e regras
```

### Como funciona

- `MockBackend` recebe uma "requisição" (método, rota, query, corpo, header `Authorization`) e devolve `statusCode` + corpo JSON, como um servidor faria.
- `MockApiService` implementa `ApiService`: monta essa requisição, espera `latency` (600 ms por padrão), converte a resposta nos models e lança `ApiException` quando o status é de erro. Depois do login, guarda o token sozinho.
- Os dados ficam em memória. Agendar e cancelar funcionam durante o uso, mas tudo volta ao conteúdo dos JSONs quando o app reinicia.
- Para trocar pelo backend real, basta criar um `HttpApiService implements ApiService` (por exemplo com o pacote `http`) e mudar uma linha na injeção de dependência. Repositórios, ViewModels e telas não mudam.

### Usuário de teste

| E-mail | Senha |
|---|---|
| `maria@saudeja.com` | `123456` |

Ela já tem uma consulta confirmada (Dra. Helena Ribeiro, qui 26/11/2026 às 09:30, como na Home do protótipo), uma realizada e uma cancelada.

### Configuração no projeto

No `pubspec.yaml`, registre a pasta de assets:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/mock/
```

Uso no app (com `provider`):

```dart
Provider<ApiService>(create: (_) => MockApiService()),
```

Nos testes, use `MockApiService(latency: Duration.zero)` ou o `MockBackend` direto.

### Servidor HTTP (opcional)

Se for exigido um backend rodando de verdade, ou para testar no Postman ou no navegador:

```
dart run tool/mock_server.dart
```

O servidor sobe em `http://localhost:8080` com as mesmas rotas. Exemplos:

```
curl http://localhost:8080/doctors?featured=true

curl -X POST http://localhost:8080/auth/login -H "Content-Type: application/json" -d "{\"email\":\"maria@saudeja.com\",\"password\":\"123456\"}"
```

> No emulador Android, o `localhost` da máquina é `http://10.0.2.2:8080`.
