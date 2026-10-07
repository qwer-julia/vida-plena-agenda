# VidaPlena Agenda

App mobile em Flutter para agendamento de consultas da Clínica Vida Plena (empresa fictícia).
Projeto Integrado UNIFEOB – Desenvolvimento Mobile, 3º trimestre de 2026.

## Objetivo
O paciente cria conta, vê especialidades/profissionais/horários, agenda, confirma, remarca e cancela consultas, e recebe lembrete local. Dados ficam no aparelho (sem backend).

## Fora do escopo
Painel web, pagamento, integração com prontuário, push remoto, backend.

## Stack
- Flutter estável + Dart (null safety)
- Estado: `provider` (ChangeNotifier)
- Persistência: `shared_preferences` (JSON) atrás de uma interface de repositório
- Lembretes: `flutter_local_notifications`
- Testes: `flutter_test`, `mocktail`

## Estrutura
```
lib/
  main.dart
  domain/          # modelos (Patient, Doctor, Appointment) e regras puras
  data/            # repositórios (interface + implementação local)
  presentation/
    pages/         # login, cadastro, home, novo agendamento, minhas consultas
    widgets/       # componentes reutilizáveis
    state/         # ChangeNotifiers (AuthState, AppointmentState)
test/
  domain/          # testes unitários
  presentation/    # testes de widget
```

## Regras de negócio
- Dois agendamentos não podem ter o mesmo profissional e o mesmo horário (status diferente de cancelada).
- Só é possível cancelar/remarcar consultas futuras.
- Status: `agendada`, `confirmada`, `cancelada`, `realizada`.
- E-mail precisa ser válido; senha com no mínimo 6 caracteres.

## Convenções
- Lógica de negócio fora dos widgets. Widgets só exibem estado e disparam ações.
- Repositórios sempre acessados por interface, para permitir mocks.
- Widgets pequenos e reutilizáveis; responsividade com `LayoutBuilder`/`MediaQuery`.
- Nomes de arquivos em `snake_case`, classes em `PascalCase`, textos da UI em português.
- Sem dependências novas sem avisar o motivo.

## Comandos
- `flutter pub get`
- `flutter analyze` (deve passar sem warnings)
- `flutter test`
- `flutter test --coverage`
- `flutter run`

## Definição de pronto de cada etapa
1. `flutter analyze` sem erros.
2. `flutter test` passando.
3. Commit pequeno com mensagem clara em português.
4. Atualizar a tabela de requisitos no README.

## Entregáveis do PI (não esquecer)
Repositório público no GitHub com README, relatório técnico, vídeo de até 10 min, casos de teste documentados.
