String? requiredText(String? v) =>
    v == null || v.trim().isEmpty ? 'This field is required' : null;
String? validateEmail(String? v) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v?.trim() ?? '')
    ? null
    : 'Enter a valid email address';
String? validatePassword(String? v) =>
    (v?.length ?? 0) >= 8 ? null : 'Use at least 8 characters';
String? validatePhone(String? v) =>
    RegExp(r'^\+?[0-9 ()-]{7,20}$').hasMatch(v?.trim() ?? '')
    ? null
    : 'Enter a valid phone number';
