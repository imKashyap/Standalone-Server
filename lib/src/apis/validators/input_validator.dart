abstract class StringValidator {
  bool isValid(String value);
}

// is valid email address
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

// is valid name
class NonEmptyString implements StringValidator {
  @override
  bool isValid(String value) {
    if (value == null) return false;
    return value.isNotEmpty;
  }
}

// is valid password
class ValidPassword implements StringValidator {
  @override
  bool isValid(String value) {
    if (value == null) return false;
    return value.length > 5;
  }
}

// error messages for invalid inputs
class InputValidator {
  final StringValidator nonEmptyTextValidator = NonEmptyString();
  final StringValidator emailValidator = ValidEmail();
  final StringValidator passValidator = ValidPassword();
  final String emptyname = 'Enter a valid name.';
  final String emailError = 'Enter a valid email.';
  final String passError = 'Enter atleast 6 characters password.';
}
