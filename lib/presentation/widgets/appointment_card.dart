import 'package:flutter/material.dart';

import '../../domain/appointment.dart';
import '../formatters.dart';
import 'status_chip.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.doctorName,
    required this.specialtyName,
    this.actions = const [],
  });

  final Appointment appointment;
  final String doctorName;
  final String specialtyName;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatDateTime(appointment.dateTime), style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(doctorName, style: textTheme.bodyLarge),
            Text(specialtyName, style: textTheme.bodyMedium),
            const SizedBox(height: 8),
            StatusChip(appointment.status),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}
