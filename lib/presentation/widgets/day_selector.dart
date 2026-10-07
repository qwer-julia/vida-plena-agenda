import 'package:flutter/material.dart';

import '../formatters.dart';

/// Linha rolável de dias para escolher a data da consulta.
class DaySelector extends StatelessWidget {
  const DaySelector({
    super.key,
    required this.days,
    required this.selected,
    required this.onSelected,
  });

  final List<DateTime> days;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = days[i];
          return ChoiceChip(
            label: Text('${weekdayShort(day)}\n${formatDay(day)}', textAlign: TextAlign.center),
            selected: day == selected,
            onSelected: (_) => onSelected(day),
          );
        },
      ),
    );
  }
}
