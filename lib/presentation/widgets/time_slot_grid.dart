import 'package:flutter/material.dart';

import '../formatters.dart';

class TimeSlotGrid extends StatelessWidget {
  const TimeSlotGrid({
    super.key,
    required this.slots,
    required this.selected,
    required this.onSelected,
  });

  final List<DateTime> slots;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Não há horários livres neste dia. Escolha outra data.'),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final slot in slots)
          ChoiceChip(
            label: Text(formatTime(slot)),
            selected: slot == selected,
            onSelected: (_) => onSelected(slot),
          ),
      ],
    );
  }
}
