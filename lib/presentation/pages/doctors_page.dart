import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/specialty.dart';
import '../state/appointment_state.dart';
import '../widgets/responsive_body.dart';
import 'schedule_page.dart';

class DoctorsPage extends StatelessWidget {
  const DoctorsPage({super.key, required this.specialty});

  final Specialty specialty;

  @override
  Widget build(BuildContext context) {
    final doctors = context.watch<AppointmentState>().doctorsFor(specialty.id);
    return Scaffold(
      appBar: AppBar(title: Text(specialty.name)),
      body: ResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Escolha o profissional',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            for (final d in doctors)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  minVerticalPadding: 16,
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(d.name),
                  subtitle: Text(specialty.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => SchedulePage(doctor: d)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
