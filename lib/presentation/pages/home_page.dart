import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/appointment_state.dart';
import '../state/auth_state.dart';
import '../widgets/error_message.dart';
import '../widgets/responsive_body.dart';
import 'doctors_page.dart';
import 'my_appointments_page.dart';

const _specialtyIcons = {
  'clinica-geral': Icons.medical_services,
  'cardiologia': Icons.favorite,
  'dermatologia': Icons.spa,
};

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final state = context.watch<AppointmentState>();
    final firstName = (auth.currentPatient?.name ?? '').split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: Text(firstName.isEmpty ? 'Início' : 'Olá, $firstName'),
        actions: [
          IconButton(
            tooltip: 'Minhas consultas',
            icon: const Icon(Icons.event_note),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MyAppointmentsPage()),
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthState>().logout(),
          ),
        ],
      ),
      body: ResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Escolha uma especialidade',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (state.error != null) ErrorMessage(state.error!),
            if (state.isLoading && state.specialties.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            for (final s in state.specialties)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  minVerticalPadding: 16,
                  leading: Icon(_specialtyIcons[s.id] ?? Icons.local_hospital, size: 32),
                  title: Text(s.name),
                  subtitle: Text('${state.doctorsFor(s.id).length} profissionais'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => DoctorsPage(specialty: s)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
