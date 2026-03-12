String? emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Vui lòng nhập email của bạn.';
  }

  // Regex kiểm tra định dạng email chuẩn
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  if (!emailRegex.hasMatch(value)) {
    return 'Email không hợp lệ (VD: ten@domain.com).';
  }

  return null;
}
