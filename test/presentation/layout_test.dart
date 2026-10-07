import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vida_plena_agenda/data/local_appointment_repository.dart';
import 'package:vida_plena_agenda/data/local_catalog_repository.dart';
import 'package:vida_plena_agenda/data/local_patient_repository.dart';
import 'package:vida_plena_agenda/main.dart';
import 'package:vida_plena_agenda/presentation/state/appointment_state.dart';
import 'package:vida_plena_agenda/presentation/state/auth_state.dart';

/// Telas de 5 a 7 polegadas (em dp) e fonte ampliada: nada pode estourar o layout.
const _sizes = {
  'pequena 5" (320x568)': Size(320, 568),
  'média (390x844)': Size(390, 844),
  'grande 7" (600x960)': Size(600, 960),
  'tablet (800x1280)': Size(800, 1280),
};

void main() {
  for (final entry in _sizes.entries) {
    for (final scale in [1.0, 1.6]) {
      testWidgets('fluxo sem overflow em ${entry.key}, fonte x$scale', (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final auth = AuthState(LocalPatientRepository(prefs));
        final appointments = AppointmentState(
          LocalAppointmentRepository(prefs),
          LocalCatalogRepository(),
        );

        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(() {
          tester.view.reset();
          tester.platformDispatcher.clearAllTestValues();
        });

        await tester.pumpWidget(VidaPlenaApp(auth: auth, appointments: appointments));
        await tester.pumpAndSettle();
        expect(find.text('Entrar'), findsWidgets); // login

        // Erros de validação visíveis (campos vazios).
        await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
        await tester.pumpAndSettle();
        expect(find.text('Informe seu e-mail.'), findsOneWidget);
        expect(find.text('Informe sua senha.'), findsOneWidget);

        // Cadastro.
        await tester.tap(find.text('Não tem conta? Cadastre-se'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Cadastrar'));
        await tester.pumpAndSettle();
        expect(find.text('Informe seu nome.'), findsOneWidget);
        await tester.enterText(find.widgetWithText(TextFormField, 'Nome completo'), 'Ana Souza');
        await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'ana@email.com');
        await tester.enterText(find.widgetWithText(TextFormField, 'Senha (mínimo 6 caracteres)'), '123456');
        await tester.ensureVisible(find.widgetWithText(FilledButton, 'Cadastrar'));
        await tester.tap(find.widgetWithText(FilledButton, 'Cadastrar'));
        await tester.pumpAndSettle();

        // Home -> profissionais -> horários -> confirmação.
        expect(find.text('Escolha uma especialidade'), findsOneWidget);
        await tester.tap(find.text('Clínica Geral'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Dra. Helena Martins'));
        await tester.pumpAndSettle();

        // Procura um dia com horários livres (chips "HH:MM").
        final timeChips = find.byWidgetPredicate((w) =>
            w is ChoiceChip &&
            w.label is Text &&
            RegExp(r'^\d\d:\d\d$').hasMatch((w.label as Text).data ?? ''));
        for (var i = 0; i < 7 && timeChips.evaluate().isEmpty; i++) {
          await tester.tap(find.byType(ChoiceChip).at(i));
          await tester.pumpAndSettle();
        }
        expect(timeChips, findsWidgets, reason: 'deve haver horários livres');
        await tester.tap(timeChips.first);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Continuar'));
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();
        expect(find.text('Resumo da consulta'), findsOneWidget);

        await tester.ensureVisible(find.widgetWithText(FilledButton, 'Confirmar agendamento'));
        await tester.tap(find.widgetWithText(FilledButton, 'Confirmar agendamento'));
        await tester.pumpAndSettle();

        // Minhas consultas com a nova consulta e ações.
        expect(find.text('Minhas consultas'), findsOneWidget);
        expect(find.text('Dra. Helena Martins'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);

        await tester.tap(find.text('Histórico'));
        await tester.pumpAndSettle();
        expect(find.text('Nenhuma consulta no histórico.'), findsOneWidget);

        expect(tester.takeException(), isNull);
      });
    }
  }
}
