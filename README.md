# VidaPlena Agenda

App mobile em Flutter para agendamento de consultas da Clínica Vida Plena (empresa fictícia).
Projeto Integrado UNIFEOB – Desenvolvimento Mobile, 3º trimestre de 2026.

## Descrição

O paciente cria conta, vê especialidades, profissionais e horários, agenda, confirma,
remarca e cancela consultas, e recebe lembrete local. Os dados ficam no aparelho (sem backend).

## Stack

- Flutter + Dart (null safety)
- Estado: `provider`
- Persistência: `shared_preferences` (JSON) atrás de uma interface de repositório
- Lembretes: `flutter_local_notifications`
- Testes: `flutter_test`, `mocktail`

## Como rodar

```
flutter pub get
flutter run
```

## Como testar

```
flutter analyze
flutter test
```

## Status

Fase 0 concluída: estrutura inicial do projeto. Telas e regras ainda não implementadas.
