class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialtyId,
    this.workingWeekdays = const [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
    ],
    this.slotHours = const [9, 10, 11, 14, 15, 16],
  });

  final String id;
  final String name;
  final String specialtyId;

  /// Dias da semana de atendimento (`DateTime.monday` a `DateTime.sunday`).
  final List<int> workingWeekdays;

  /// Horas cheias de atendimento em cada dia de trabalho.
  final List<int> slotHours;

  /// Horários possíveis do profissional em [day] (vazio fora dos dias de atendimento).
  List<DateTime> slotsOn(DateTime day) {
    if (!workingWeekdays.contains(day.weekday)) return const [];
    return [
      for (final h in slotHours) DateTime(day.year, day.month, day.day, h),
    ];
  }
}
