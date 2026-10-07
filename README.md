# VidaPlena Agenda

App mobile em Flutter para agendamento de consultas da Clínica Vida Plena (empresa fictícia).
Projeto Integrado UNIFEOB – Desenvolvimento Mobile, 3º trimestre de 2026.

## Identificação

| Item | Informação |
|---|---|
| Instituição | UNIFEOB – Centro Universitário da Fundação de Ensino Octávio Bastos, Escola de Negócios e Tecnologia EAD |
| Curso | Análise e Desenvolvimento de Sistemas |
| Módulo | Desenvolvimento Mobile – 3º trimestre letivo de 2026 |
| Projeto | Projeto Integrado (PI) – aplicativo mobile em Flutter |
| Estudante | Júlia Silva da Fonseca – RA 24002057 |
| Orientadora | Profa. Mariangela Martimbianco Santos |
| Local e data | São João da Boa Vista, SP – outubro de 2026 |

## Descrição

O paciente cria conta, vê especialidades, profissionais e horários, agenda, confirma,
remarca e cancela consultas, e recebe lembrete local. Os dados ficam no aparelho (sem backend).

## Stack

- Flutter + Dart (null safety)
- Estado: `provider`
- Persistência: `shared_preferences` (JSON) atrás de uma interface de repositório
- Lembretes: `flutter_local_notifications`
- Senha: hash PBKDF2-HMAC-SHA256 com salt por usuário (`crypto`)
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
| RNF04 | Proteção dos dados | Implementado | Dados só no aparelho, sem backend; a senha é gravada apenas como hash PBKDF2 com salt (dados antigos em texto são migrados ao ler) |
| RF02 | Especialidades e horários | Implementado | Catálogo local com profissionais e horários por dia |
| RF03 | Novo agendamento | Implementado | Fluxo especialidade → profissional → horário → confirmação |
| RF04 | Validação de conflito | Implementado | Mesmo profissional e horário bloqueado (canceladas não contam) |
| RF05 | Minhas consultas | Implementado | Abas Futuras e Histórico |
| RF06 | Confirmar, remarcar, cancelar | Implementado | Só consultas futuras |
| RF07 | Lembrete | Implementado | 24 h antes (ou 1 h antes se faltar menos); cancela ao cancelar/remarcar. Testado com mock e em aparelho real (Samsung Galaxy M35, Android): a notificação chegou no horário programado |

## Status

Fases 0 a 5 concluídas (estrutura, domínio, dados, estado, telas, lembretes).
Testes de widget dedicados (CT05, CT06) prontos. Próximo: capturas de tela, relatório e vídeo.
