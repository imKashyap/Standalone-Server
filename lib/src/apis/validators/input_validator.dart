abstract class StringValidator {
  bool isValid(String value);
}

class ValidEmail implements StringValidator {
  @override
  bool isValid(String value) {
    if (value == null) return false;
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    var regex =  RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }
}

class NonEmptyString implements StringValidator {
  @override
  bool isValid(String value) {
    if (value == null) return false;
    return value.isNotEmpty;
  }
}

class ValidPassword implements StringValidator {
  @override
  bool isValid(String value) {
    if (value == null) return false;
    return value.length > 5;
  }
}

class ValidPhoneNo implements StringValidator {
  @override
  bool isValid(String value) {
    if (value == null) return false;
    var patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    var regExp = RegExp(patttern);
    return (value.isEmpty || !regExp.hasMatch(value));
  }
}

class ValidOtp implements StringValidator {
  @override
  bool isValid(String value) {
    if (value == null) return false;
    return value.length == 6 && int.tryParse(value) != null;
  }
}

class InputValidator {
  final StringValidator nonEmptyTextValidator = NonEmptyString();
  final StringValidator emailValidator = ValidEmail();
  final StringValidator passValidator = ValidPassword();
  final StringValidator phoneValidator = ValidPhoneNo();
  final StringValidator otpValidator = ValidOtp();
  final String emptyname = 'Enter a valid name.';
  final String emailError = 'Enter a valid email.';
  final String passError = 'Enter atleast 6 characters password.';
  final String phoneError = 'Enter a valid phone number.';
  final String otpError = 'Enter a valid 6 digit otp.';
}
