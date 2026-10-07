import '../domain/appointment.dart';

const _weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

String _two(int n) => n.toString().padLeft(2, '0');

String weekdayShort(DateTime d) => _weekdays[d.weekday - 1];

String formatDay(DateTime d) => '${_two(d.day)}/${_two(d.month)}';

String formatDate(DateTime d) => '${formatDay(d)}/${d.year}';

String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

String formatDateTime(DateTime d) =>
    '${weekdayShort(d)}, ${formatDate(d)} às ${formatTime(d)}';

String statusLabel(AppointmentStatus s) => switch (s) {
      AppointmentStatus.agendada => 'Agendada',
      AppointmentStatus.confirmada => 'Confirmada',
      AppointmentStatus.cancelada => 'Cancelada',
      AppointmentStatus.realizada => 'Realizada',
    };
