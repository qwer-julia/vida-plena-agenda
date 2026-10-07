import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/doctor.dart';
import '../formatters.dart';
import '../state/appointment_state.dart';
import '../widgets/app_button.dart';
import '../widgets/day_selector.dart';
import '../widgets/responsive_body.dart';
import '../widgets/time_slot_grid.dart';
import 'confirmation_page.dart';

/// Escolha de dia e horário. No modo [reschedule], devolve o horário escolhido
/// via `Navigator.pop`; no modo normal, segue para a confirmação do agendamento.
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required this.doctor, this.reschedule = false});

  final Doctor doctor;
  final bool reschedule;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const _daysAhead = 21;

  late final List<DateTime> _days;
  late DateTime _day;
  DateTime? _slot;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _days = [
      for (var i = 0; i < _daysAhead; i++)
        DateTime(today.year, today.month, today.day + i),
    ];
    _day = _days.first;
  }

  void _continue() {
    final slot = _slot;
    if (slot == null) return;
    if (widget.reschedule) {
      Navigator.of(context).pop(slot);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ConfirmationPage(doctor: widget.doctor, dateTime: slot),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slots = context.watch<AppointmentState>().availableSlots(widget.doctor, _day);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reschedule ? 'Remarcar consulta' : widget.doctor.name),
      ),
      body: ResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.reschedule)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(widget.doctor.name,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            Text('Dia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DaySelector(
              days: _days,
              selected: _day,
              onSelected: (d) => setState(() {
                _day = d;
                _slot = null;
              }),
            ),
            const SizedBox(height: 24),
            Text('Horário', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TimeSlotGrid(
              slots: slots,
              selected: _slot,
              onSelected: (s) => setState(() => _slot = s),
            ),
            const SizedBox(height: 32),
            if (_slot != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Selecionado: ${formatDateTime(_slot!)}',
                    textAlign: TextAlign.center),
              ),
            AppButton(
              label: widget.reschedule ? 'Remarcar para este horário' : 'Continuar',
              onPressed: _slot == null ? null : _continue,
            ),
          ],
        ),
      ),
    );
  }
}
