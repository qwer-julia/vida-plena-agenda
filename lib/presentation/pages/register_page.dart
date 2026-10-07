import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/validators.dart';
import '../state/auth_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/error_message.dart';
import '../widgets/responsive_body.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final ok = await context.read<AuthState>().register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
    // Com a sessão aberta, o AuthGate troca para a home; volta à raiz.
    if (ok) navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: ResponsiveBody(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _name,
                label: 'Nome completo',
                autofillHints: const [AutofillHints.name],
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe seu nome.' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _email,
                label: 'E-mail',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: (v) => Validators.isValidEmail(v ?? '')
                    ? null
                    : 'Informe um e-mail válido.',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _password,
                label: 'Senha (mínimo 6 caracteres)',
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: _submit,
                validator: (v) => Validators.isValidPassword(v ?? '')
                    ? null
                    : 'A senha deve ter no mínimo ${Validators.minPasswordLength} caracteres.',
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 16),
                ErrorMessage(auth.error!),
              ],
              const SizedBox(height: 24),
              AppButton(label: 'Cadastrar', loading: auth.isLoading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
