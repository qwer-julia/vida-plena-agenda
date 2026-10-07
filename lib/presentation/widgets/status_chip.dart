import 'package:flutter/material.dart';

import '../../domain/appointment.dart';
import '../formatters.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      AppointmentStatus.agendada => (Colors.blue.shade800, Icons.schedule),
      AppointmentStatus.confirmada => (Colors.green.shade800, Icons.check_circle),
      AppointmentStatus.cancelada => (Colors.red.shade800, Icons.cancel),
      AppointmentStatus.realizada => (Colors.grey.shade800, Icons.done_all),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          statusLabel(status),
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
