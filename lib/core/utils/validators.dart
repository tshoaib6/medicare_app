class Validators {
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? zipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ZIP code is required';
    }
    // US ZIP code validation (5 digits or 5-4 format)
    if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(value.trim())) {
      return 'Please enter a valid ZIP code';
    }
    return null;
  }

  static String? yearOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Year of birth is required';
    }

    final year = int.tryParse(value.trim());
    if (year == null) {
      return 'Please enter a valid year';
    }

    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear) {
      return 'Please enter a valid birth year';
    }

    // Check if person is at least 18 years old
    if (currentYear - year < 18) {
      return 'You must be at least 18 years old';
    }

    return null;
  }

  static String? otpCode(String? value, {int length = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Verification code is required';
    }
    if (value.length != length) {
      return 'Please enter the complete $length-digit code';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Verification code should only contain numbers';
    }
    return null;
  }

  static String? name(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return '$fieldName should only contain letters and spaces';
    }
    return null;
  }

  // Format phone number as (XXX) XXX-XXXX
  static String formatPhoneNumber(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length == 10) {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    }
    return phoneNumber;
  }

  // Remove phone number formatting
  static String unformatPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  }

  // Format ZIP code as XXXXX-XXXX if needed
  static String formatZipCode(String zipCode) {
    final digitsOnly = zipCode.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length == 9) {
      return '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5)}';
    }
    return zipCode;
  }
}
