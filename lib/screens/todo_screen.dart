import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/todo.dart';
import '../utils/error_messages.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _client = Supabase.instance.client;
  final _newTodoController = TextEditingController();

  List<Todo> _todos = const [];
  bool _loading = true;
  String? _error;

  String get _email =>
      _client.auth.currentUser?.email ?? '(email tidak tersedia)';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _newTodoController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final rows = await _client
          .from('todos')
          .select()
          .order('is_done', ascending: true)
          .order('created_at', ascending: false);

      if (!mounted) {
        return;
      }
      setState(() {
        _todos = rows.map(Todo.fromMap).toList();
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = messageForError(error);
        _loading = false;
      });
    }
  }

  Future<void> _showAddTodoDialog() async {
    _newTodoController.clear();

    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('To-Do Baru'),
        content: TextField(
          controller: _newTodoController,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Judul to-do',
            hintText: 'Contoh: Belajar Flutter',
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_newTodoController.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    final trimmedTitle = title?.trim() ?? '';
    if (trimmedTitle.isEmpty) {
      return;
    }
    await _insertTodo(trimmedTitle);
  }

  Future<void> _insertTodo(String title) async {
    try {
      await _client.from('todos').insert({
        'title': title,
        'user_id': _client.auth.currentUser!.id,
      });
      await _loadTodos(showSpinner: false);
    } catch (error) {
      _showMessage(messageForError(error));
    }
  }

  Future<void> _toggleTodo(Todo todo) async {
    try {
      await _client
          .from('todos')
          .update({'is_done': !todo.isDone})
          .eq('id', todo.id);
      await _loadTodos(showSpinner: false);
    } catch (error) {
      _showMessage(messageForError(error));
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus to-do'),
        content: Text('Hapus "${todo.title}" dari daftar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _client.from('todos').delete().eq('id', todo.id);
      await _loadTodos(showSpinner: false);
    } catch (error) {
      _showMessage(messageForError(error));
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: Text('Keluar dari akun $_email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _client.auth.signOut();
    } catch (error) {
      _showMessage(messageForError(error));
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: Column(
        children: [
          _AccountHeader(email: _email, onLogout: _logout),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTodoDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _CenteredMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Gagal memuat data',
        description: _error!,
        actionLabel: 'Coba lagi',
        onAction: _loadTodos,
      );
    }

    if (_todos.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadTodos(showSpinner: false),
        child: const _CenteredMessage(
          icon: Icons.inbox_outlined,
          title: 'Belum ada to-do',
          description: 'Tekan tombol Tambah untuk membuat to-do pertamamu.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadTodos(showSpinner: false),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
        itemCount: _todos.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final todo = _todos[index];
          final colorScheme = Theme.of(context).colorScheme;

          return ListTile(
            leading: Checkbox(
              value: todo.isDone,
              onChanged: (_) => _toggleTodo(todo),
            ),
            title: Text(
              todo.title,
              style: todo.isDone
                  ? TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),
            subtitle: Text(todo.formattedDate),
            trailing: IconButton(
              tooltip: 'Hapus',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteTodo(todo),
            ),
            onTap: () => _toggleTodo(todo),
          );
        },
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.email, required this.onLogout});

  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(
                  email.isEmpty ? '?' : email.characters.first.toUpperCase(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Masuk sebagai', style: textTheme.labelMedium),
                    Text(
                      email,
                      style: textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(title, style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: onAction,
                      child: Text(actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
