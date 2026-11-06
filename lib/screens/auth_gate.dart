import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';
import 'todo_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        auth.currentSession,
      ),
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;

        if (session == null) {
          return const LoginScreen();
        }
        return const TodoScreen();
      },
    );
  }
}
