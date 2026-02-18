import 'package:flutter_riverpod/legacy.dart';

class SignUpFormState {
  const SignUpFormState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

  SignUpFormState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
  }) {
    return SignUpFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
    );
  }
}


class SignUpFormNotifier extends StateNotifier<SignUpFormState> {
  SignUpFormNotifier() : super(const SignUpFormState());

  void validateEmail(String email) {

    final emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (email.isEmpty) {
      state = state.copyWith(emailError: 'Email cannot be empty.');
    } else if (!emailRegex.hasMatch(email)) {
      state = state.copyWith(emailError: 'Please enter a valid email.');
    } else {
      state = state.copyWith(emailError: null);
    }
    state = state.copyWith(email: email);
  }

  void validatePassword(String password) {

    if (password.isEmpty ) {
     
      state = state.copyWith(password: password,passwordError: 'Password cannot be empty.');
    } else if (password.length < 6) {
  
      state = state.copyWith(password: password,passwordError: 'Password must be at least 6 characters.');
    } else {
   
      state = state.copyWith(password: password,passwordError: null);
    }

    if (state.confirmPassword.isNotEmpty) {
      validateConfirmPassword(state.confirmPassword);
    }
  }

  void validateConfirmPassword(String confirmPassword) {
    if (confirmPassword.isEmpty) {
      state = state.copyWith(confirmPassword: confirmPassword,confirmPasswordError: 'Please confirm your password.');
    } else if (confirmPassword != state.password) {
      state = state.copyWith(confirmPassword: confirmPassword,confirmPasswordError: 'Passwords do not match.');
    } else {
      state = state.copyWith(confirmPassword: confirmPassword,confirmPasswordError: null);
    }
  }

  bool isFormValid() {
    return state.emailError == null &&
        state.passwordError == null &&
        state.confirmPasswordError == null &&
        state.email.isNotEmpty &&
        state.password.isNotEmpty &&
        state.confirmPassword.isNotEmpty;
  }
}


final signUpFormProvider = StateNotifierProvider<SignUpFormNotifier, SignUpFormState>((ref) {
  return SignUpFormNotifier();
});