class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  static String? maxLength(String? value, int max) {
    if (value == null) return null;
    if (value.length > max) {
      return 'Must be less than $max characters';
    }
    return null;
  }
}
