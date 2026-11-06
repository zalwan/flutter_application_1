final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Email wajib diisi.';
  }
  if (!_emailPattern.hasMatch(email)) {
    return 'Format email tidak valid.';
  }
  return null;
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) {
    return 'Password wajib diisi.';
  }
  if (password.length < 6) {
    return 'Password minimal 6 karakter.';
  }
  return null;
}
