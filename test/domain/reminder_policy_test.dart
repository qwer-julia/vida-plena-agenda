import 'package:flutter_test/flutter_test.dart';
import 'package:vida_plena_agenda/domain/reminder_policy.dart';

void main() {
  final now = DateTime(2026, 10, 6, 12);

  test('avisa 24 horas antes quando há tempo', () {
    final at = DateTime(2026, 10, 9, 9);
    expect(reminderTimeFor(at, now), DateTime(2026, 10, 8, 9));
  });

  test('sem 24 horas de folga, avisa 1 hora antes', () {
    final at = DateTime(2026, 10, 7, 9);
    expect(reminderTimeFor(at, now), DateTime(2026, 10, 7, 8));
  });

  test('consulta em menos de 1 hora não gera lembrete', () {
    expect(reminderTimeFor(DateTime(2026, 10, 6, 12, 30), now), isNull);
  });
}
