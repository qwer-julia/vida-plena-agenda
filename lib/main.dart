import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/local_appointment_repository.dart';
import 'data/local_catalog_repository.dart';
import 'data/local_patient_repository.dart';
import 'presentation/app_theme.dart';
import 'presentation/pages/auth_gate.dart';
import 'presentation/state/appointment_state.dart';
import 'presentation/state/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final auth = AuthState(LocalPatientRepository(prefs));
  final appointments = AppointmentState(
    LocalAppointmentRepository(prefs),
    LocalCatalogRepository(),
  );
  await auth.restoreSession();

  runApp(VidaPlenaApp(auth: auth, appointments: appointments));
}

class VidaPlenaApp extends StatelessWidget {
  const VidaPlenaApp({super.key, required this.auth, required this.appointments});

  final AuthState auth;
  final AppointmentState appointments;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthState>.value(value: auth),
        ChangeNotifierProvider<AppointmentState>.value(value: appointments),
      ],
      child: MaterialApp(
        title: 'VidaPlena Agenda',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}
