extension extString on String {
  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(this);
  }

  bool get isValidName{
    final nameRegExp = new RegExp(r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$");
    return nameRegExp.hasMatch(this);
  }

  bool get isValidPassword{
    final passwordRegExp = new RegExp(r'^.{6,}$');
    return passwordRegExp.hasMatch(this);
  }

  bool get isNotNull{
    return this!=null;
  }

  bool get isValidPhone{
    final phoneRegExp = new RegExp(r"^\+?0[0-9]{9}$");
    return phoneRegExp.hasMatch(this);
  }

  bool get isValidID{
    final idRegExp = RegExp(r"^\+?[0-9][0-9][0-9]{3}$");
    return idRegExp.hasMatch(this);
  }

  bool get isValidDate{
    final dateRegExp = RegExp(r"^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$");
    return dateRegExp.hasMatch(this);
  }
}
