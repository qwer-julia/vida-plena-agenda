import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/doctor.dart';
import '../formatters.dart';
import '../state/appointment_state.dart';
import '../widgets/app_button.dart';
import '../widgets/error_message.dart';
import '../widgets/responsive_body.dart';
import 'my_appointments_page.dart';

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({super.key, required this.doctor, required this.dateTime});

  final Doctor doctor;
  final DateTime dateTime;

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppointmentState>().clearError();
    });
  }

  Future<void> _book() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<AppointmentState>().book(widget.doctor, widget.dateTime);
    if (!ok) return;
    navigator.popUntil((route) => route.isFirst);
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => const MyAppointmentsPage()),
    );
    messenger.showSnackBar(
      const SnackBar(content: Text('Consulta agendada com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppointmentState>();
    final specialty = state.specialties
        .where((s) => s.id == widget.doctor.specialtyId)
        .map((s) => s.name)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar agendamento')),
      body: ResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumo da consulta',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _Row(Icons.person, widget.doctor.name),
                    if (specialty != null) _Row(Icons.medical_services, specialty),
                    _Row(Icons.calendar_today, formatDate(widget.dateTime)),
                    _Row(Icons.access_time, formatTime(widget.dateTime)),
                  ],
                ),
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 16),
              ErrorMessage(state.error!),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: 'Confirmar agendamento',
              loading: state.isLoading,
              onPressed: _book,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: state.isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
