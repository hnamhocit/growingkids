String? passwordValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Vui lòng nhập mật khẩu.';
  }

  // Regex: Ít nhất 8 ký tự, 1 hoa, 1 thường, 1 số
  final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d\w\W]{8,}$',
  );

  if (!passwordRegex.hasMatch(value)) {
    return 'Mật khẩu phải từ 8 ký tự, gồm chữ in hoa, in thường và số.';
  }
  return null;
}
