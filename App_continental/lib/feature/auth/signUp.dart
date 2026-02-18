import 'package:continental/feature/auth/signupFormPro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_provider.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final signUpFormState = ref.watch(signUpFormProvider);
    final signUpFormNotifier = ref.read(signUpFormProvider.notifier);

    // Your existing providers for password visibility
    final isPasswordObscured = ref.watch(signUpPasswordVisibilityProvider);
    final isConfirmPasswordObscured = ref.watch(confirmPasswordVisibilityProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
             
                Image.asset(
                  'assets/images/logo.png',
                  height: 50,
                ),
                const SizedBox(height: 50),
                Text(
                  'Create Account',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter your details below to create your\naccount and get started.',
                  style: GoogleFonts.inter(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
             
                Text(
                  'Name',
                  style: GoogleFonts.inter(color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey[800]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.yellow),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
             
                Text(
                  'Email',
                  style: GoogleFonts.inter(color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                TextField(
               
                  onChanged: (value) => signUpFormNotifier.validateEmail(value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'xyz@gmail.com',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[900],
                
                    errorText: signUpFormState.emailError,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey[800]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.yellow),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
          
                Text(
                  'Password',
                  style: GoogleFonts.inter(color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => signUpFormNotifier.validatePassword(value),
                  obscureText: isPasswordObscured,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '********',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    errorText: signUpFormState.passwordError,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey[800]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.yellow),
                    ),
                     errorStyle: const TextStyle(color: Colors.redAccent),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        ref.read(signUpPasswordVisibilityProvider.notifier).state = !isPasswordObscured;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
               
                Text(
                  'Confirm Password',
                  style: GoogleFonts.inter(color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => signUpFormNotifier.validateConfirmPassword(value),
                  obscureText: isConfirmPasswordObscured,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '********',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    errorText: signUpFormState.confirmPasswordError,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey[800]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.yellow),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        ref.read(confirmPasswordVisibilityProvider.notifier).state = !isConfirmPasswordObscured;
                       
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
         
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                       context.goNamed('bottomNavBar');
                      // if (signUpFormNotifier.isFormValid()) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(content: Text('Sign-up successful!')),
                      //   );
                       
                      // } else {
                      //   // Form is invalid, show a message
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(
                      //       content: Text('Please correct the errors in the form.'),
                      //       backgroundColor: Colors.red,
                      //     ),
                      //   );
                      // }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Sign up',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
             
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                        
                          context.goNamed('login');
                        },
                        child: Text(
                          'Sign in now',
                          style: GoogleFonts.inter(
                            color: Colors.yellow[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}