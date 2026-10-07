import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/appointment.dart';
import '../state/appointment_state.dart';
import '../widgets/appointment_card.dart';
import '../widgets/error_message.dart';
import 'schedule_page.dart';

class MyAppointmentsPage extends StatelessWidget {
  const MyAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppointmentState>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minhas consultas'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Futuras'), Tab(text: 'Histórico')],
          ),
        ),
        body: Column(
          children: [
            if (state.isLoading) const LinearProgressIndicator(),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ErrorMessage(state.error!),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  _AppointmentList(
                    appointments: state.upcoming,
                    emptyText: 'Você não tem consultas futuras.',
                    showActions: true,
                  ),
                  _AppointmentList(
                    appointments: state.history,
                    emptyText: 'Nenhuma consulta no histórico.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({
    required this.appointments,
    required this.emptyText,
    this.showActions = false,
  });

  final List<Appointment> appointments;
  final String emptyText;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(emptyText, textAlign: TextAlign.center),
        ),
      );
    }
    final state = context.read<AppointmentState>();
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final a in appointments)
              AppointmentCard(
                appointment: a,
                doctorName: state.doctorById(a.doctorId)?.name ?? 'Profissional',
                specialtyName: state.specialties
                        .where((s) => s.id == state.doctorById(a.doctorId)?.specialtyId)
                        .map((s) => s.name)
                        .firstOrNull ??
                    '',
                actions: showActions ? _actions(context, a) : const [],
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(BuildContext context, Appointment a) {
    return [
      if (a.status == AppointmentStatus.agendada)
        FilledButton.tonal(
          onPressed: () => _run(context, context.read<AppointmentState>().confirm(a.id), 'Consulta confirmada.'),
          child: const Text('Confirmar'),
        ),
      OutlinedButton(
        onPressed: () => _reschedule(context, a),
        child: const Text('Remarcar'),
      ),
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
        onPressed: () => _cancel(context, a),
        child: const Text('Cancelar'),
      ),
    ];
  }

  Future<void> _reschedule(BuildContext context, Appointment a) async {
    final state = context.read<AppointmentState>();
    final doctor = state.doctorById(a.doctorId);
    if (doctor == null) return;
    final newTime = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        builder: (_) => SchedulePage(doctor: doctor, reschedule: true),
      ),
    );
    if (newTime == null || !context.mounted) return;
    await _run(context, state.reschedule(a.id, newTime), 'Consulta remarcada.');
  }

  Future<void> _cancel(BuildContext context, Appointment a) async {
    final state = context.read<AppointmentState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar consulta?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Manter consulta'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancelar consulta'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _run(context, state.cancel(a.id), 'Consulta cancelada.');
  }

  Future<void> _run(BuildContext context, Future<bool> action, String success) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await action;
    if (ok) messenger.showSnackBar(SnackBar(content: Text(success)));
  }
}
