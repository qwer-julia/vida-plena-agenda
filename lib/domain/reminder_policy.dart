/// Quando avisar o paciente: 24 horas antes da consulta. Se esse momento já
/// passou, 1 hora antes. Devolve `null` se nem isso é possível.
DateTime? reminderTimeFor(DateTime appointment, DateTime now) {
  for (final lead in const [Duration(hours: 24), Duration(hours: 1)]) {
    final at = appointment.subtract(lead);
    if (at.isAfter(now)) return at;
  }
  return null;
}
