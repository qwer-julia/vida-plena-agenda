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

## Requisitos

| Requisito | Tela ou módulo | Situação | Observação |
|---|---|---|---|
| RF01 | Cadastro e login | Implementado | Validação de e-mail e senha (mín. 6), sessão restaurada ao abrir |
| RF02 | Especialidades e horários | Implementado | Catálogo local com profissionais e horários por dia |
| RF03 | Novo agendamento | Implementado | Fluxo especialidade → profissional → horário → confirmação |
| RF04 | Validação de conflito | Implementado | Mesmo profissional e horário bloqueado (canceladas não contam) |
| RF05 | Minhas consultas | Implementado | Abas Futuras e Histórico |
| RF06 | Confirmar, remarcar, cancelar | Implementado | Só consultas futuras |
| RF07 | Lembrete | Implementado (verificar no aparelho) | 24 h antes (ou 1 h antes se faltar menos); cancela ao cancelar/remarcar. Testado com mock; envio real ainda não testado em aparelho |

## Status

Fases 0 a 5 concluídas (estrutura, domínio, dados, estado, telas, lembretes).
Testes de widget dedicados (CT05, CT06) prontos. Próximo: capturas de tela, relatório e vídeo.
