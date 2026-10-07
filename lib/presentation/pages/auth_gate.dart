import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/appointment_state.dart';
import '../state/auth_state.dart';
import 'home_page.dart';
import 'login_page.dart';

/// Decide entre login e home e mantém o [AppointmentState] sincronizado com a sessão.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = context.watch<AuthState>().currentPatient;
    final appointments = context.read<AppointmentState>();

    if (patient == null) {
      if (appointments.patientId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => appointments.reset());
      }
      return const LoginPage();
    }
    if (appointments.patientId != patient.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) => appointments.load(patient.id));
    }
    return const HomePage();
  }
}
