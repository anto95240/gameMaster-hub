import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gamemaster_hub/presentation/core/blocs/auth/auth_bloc.dart';

class AuthForm extends StatefulWidget {
  final TabController tabController;
  const AuthForm({required this.tabController, super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final loading = state is AuthLoading;
        return Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_emailController, 'Email', Icons.email, !loading),
              const SizedBox(height: 16),
              _field(_passwordController, 'Mot de passe', Icons.lock, !loading, obscure: _obscure, toggle: () {
                setState(() => _obscure = !_obscure);
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.tabController.index == 0 ? 'Se connecter' : 'S\'inscrire'),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, bool enabled,
      {bool obscure = false, VoidCallback? toggle}) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      obscureText: obscure,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), suffixIcon: toggle != null
          ? IconButton(icon: Icon(obscure ? Icons.visibility : Icons.visibility_off), onPressed: toggle)
          : null),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Veuillez entrer $label';
        if (label == 'Email' && !v.contains('@')) return 'Email invalide';
        if (label == 'Mot de passe' && v.length < 6) return '6 caractères minimum';
        return null;
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final pass = _passwordController.text;
      final bloc = context.read<AuthBloc>();
      if (widget.tabController.index == 0) {
        bloc.add(AuthSignInRequested(email: email, password: pass));
      } else {
        bloc.add(AuthSignUpRequested(email: email, password: pass));
      }
    }
  }
}
