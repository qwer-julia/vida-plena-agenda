import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/validators.dart';
import '../state/auth_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/error_message.dart';
import '../widgets/responsive_body.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthState>().login(
          email: _email.text,
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    return Scaffold(
      appBar: AppBar(title: const Text('VidaPlena Agenda')),
      body: ResponsiveBody(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Entrar', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              const Text('Acesse sua conta para agendar consultas.'),
              const SizedBox(height: 24),
              AppTextField(
                controller: _email,
                label: 'E-mail',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe seu e-mail.'
                    : (Validators.isValidEmail(v) ? null : 'Informe um e-mail válido.'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _password,
                label: 'Senha',
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: _submit,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Informe sua senha.'
                    : (Validators.isValidPassword(v)
                        ? null
                        : 'A senha deve ter no mínimo ${Validators.minPasswordLength} caracteres.'),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 16),
                ErrorMessage(auth.error!),
              ],
              const SizedBox(height: 24),
              AppButton(label: 'Entrar', loading: auth.isLoading, onPressed: _submit),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  auth.clearError();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text('Não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
