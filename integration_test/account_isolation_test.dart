import 'package:flutter_application_1/config/supabase_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _password = 'TodoApp123!';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('setiap akun hanya melihat to-do miliknya sendiri', (
    tester,
  ) async {
    expect(
      SupabaseConfig.isConfigured,
      isTrue,
      reason:
          'Jalankan test dengan: flutter test integration_test -d <device> '
          '--dart-define-from-file=dart_defines.json',
    );

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    final client = Supabase.instance.client;

    final suffix = DateTime.now().millisecondsSinceEpoch;
    final emailA = 'todo.e2e.a.$suffix@example.com';
    final emailB = 'todo.e2e.b.$suffix@example.com';

    final signUpA = await client.auth.signUp(
      email: emailA,
      password: _password,
    );
    expect(
      signUpA.session,
      isNotNull,
      reason:
          'Matikan "Confirm email" di Supabase Dashboard > Authentication > '
          'Sign In / Providers > Email agar registrasi langsung mendapat sesi.',
    );
    final userA = signUpA.user!;

    await client.from('todos').insert([
      {'title': 'Tugas milik A - 1', 'user_id': userA.id},
      {'title': 'Tugas milik A - 2', 'user_id': userA.id},
    ]);

    final todosA = await client.from('todos').select();
    expect(todosA.length, 2);
    expect(todosA.every((row) => row['user_id'] == userA.id), isTrue);
    final idTugasA = todosA.first['id'] as String;

    await client.auth.signOut();
    final signUpB = await client.auth.signUp(
      email: emailB,
      password: _password,
    );
    final userB = signUpB.user!;
    expect(userB.id, isNot(userA.id));

    await client.from('todos').insert({
      'title': 'Tugas milik B - 1',
      'user_id': userB.id,
    });

    final todosB = await client.from('todos').select();
    expect(todosB.length, 1);
    expect(todosB.single['title'], 'Tugas milik B - 1');
    expect(todosB.any((row) => row['user_id'] == userA.id), isFalse);

    final aksesLangsung = await client
        .from('todos')
        .select()
        .eq('id', idTugasA);
    expect(aksesLangsung, isEmpty);

    await expectLater(
      client.from('todos').insert({
        'title': 'Tugas palsu atas nama A',
        'user_id': userA.id,
      }),
      throwsA(isA<PostgrestException>()),
    );

    await client.from('todos').update({'is_done': true}).eq('id', idTugasA);
    await client.from('todos').delete().eq('id', idTugasA);

    await client.auth.signOut();
    await client.auth.signInWithPassword(email: emailA, password: _password);

    final todosASetelahB = await client.from('todos').select();
    expect(todosASetelahB.length, 2);
    expect(todosASetelahB.every((row) => row['is_done'] == false), isTrue);

    await client.from('todos').delete().eq('user_id', userA.id);
    expect(await client.from('todos').select(), isEmpty);

    await client.auth.signOut();
    await client.auth.signInWithPassword(email: emailB, password: _password);
    await client.from('todos').delete().eq('user_id', userB.id);
    expect(await client.from('todos').select(), isEmpty);

    await client.auth.signOut();
    expect(client.auth.currentSession, isNull);
  });
}
