import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vida_plena_agenda/data/local_appointment_repository.dart';
import 'package:vida_plena_agenda/data/local_catalog_repository.dart';
import 'package:vida_plena_agenda/data/local_patient_repository.dart';
import 'package:vida_plena_agenda/main.dart';
import 'package:vida_plena_agenda/presentation/state/appointment_state.dart';
import 'package:vida_plena_agenda/presentation/state/auth_state.dart';

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(VidaPlenaApp(
    auth: AuthState(LocalPatientRepository(prefs)),
    appointments: AppointmentState(
      LocalAppointmentRepository(prefs),
      LocalCatalogRepository(),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('CT05: login com campos vazios mostra erros nos campos', (tester) async {
    await pumpApp(tester);

    await tapVisible(tester, find.widgetWithText(FilledButton, 'Entrar'));

    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
  });

  testWidgets('CT06: novo agendamento aparece em Minhas consultas', (tester) async {
    await pumpApp(tester);

    await tapVisible(tester, find.text('Não tem conta? Cadastre-se'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome completo'), 'Ana Souza');
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'ana@email.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha (mínimo 6 caracteres)'), '123456');
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Cadastrar'));

    await tapVisible(tester, find.text('Clínica Geral'));
    await tapVisible(tester, find.text('Dra. Helena Martins'));

    final timeChips = find.byWidgetPredicate((w) =>
        w is ChoiceChip &&
        w.label is Text &&
        RegExp(r'^\d\d:\d\d$').hasMatch((w.label as Text).data ?? ''));
    for (var i = 0; i < 7 && timeChips.evaluate().isEmpty; i++) {
      await tapVisible(tester, find.byType(ChoiceChip).at(i));
    }
    await tapVisible(tester, timeChips.first);
    await tapVisible(tester, find.text('Continuar'));
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Confirmar agendamento'));

    expect(find.text('Minhas consultas'), findsOneWidget);
    expect(find.text('Dra. Helena Martins'), findsOneWidget);
    expect(find.text('Agendada'), findsOneWidget);
  });
}
