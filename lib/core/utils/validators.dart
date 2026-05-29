class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return "L'email est requis";
    final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!re.hasMatch(value)) return 'Email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est requis';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName est requis';
    return null;
  }

  static String? positiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName est requis';
    final n = double.tryParse(value);
    if (n == null || n <= 0) return '$fieldName doit être un nombre positif';
    return null;
  }

  static String? positiveInt(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName est requis';
    final n = int.tryParse(value);
    if (n == null || n <= 0) return '$fieldName doit être un entier positif';
    return null;
  }
}
