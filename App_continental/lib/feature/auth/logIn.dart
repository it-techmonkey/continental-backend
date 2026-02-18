import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_state_provider.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authStateProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          context.goNamed('bottomnav');
        } else {
          final errorMessage = ref.read(authStateProvider).errorMessage ?? 'Login failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordObscured = ref.watch(passwordVisibilityProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: GestureDetector(
        // dismiss keyboard on background tap
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;

              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 24),
                child: ConstrainedBox(
                  // 👇 gives the Column a bounded height so Spacer/Expanded can be used
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    // allows Spacer to push the bottom row when there's space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        Image.asset('assets/images/logo.png'),
                        const SizedBox(height: 10),
                        Text(
                          'Welcome Back!',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Nice to See you Again Enter your Credentials to\nManage your Properties',
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 40                        ),

                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email', style: GoogleFonts.inter(color: Colors.grey[400])),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'xyz@gmail.com',
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
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.red),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.red),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Text('Password', style: GoogleFonts.inter(color: Colors.grey[400])),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: isPasswordObscured,
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _handleLogin(),
                                decoration: InputDecoration(
                                  hintText: '********',
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
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.red),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.red),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      ref.read(passwordVisibilityProvider.notifier).state =
                                          !isPasswordObscured;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Switch(
                                  value: true,
                                  onChanged: (value) {},
                                  activeColor: Colors.yellow,
                                  activeTrackColor: Colors.yellow.withOpacity(0.5),
                                  inactiveThumbColor: Colors.grey,
                                  inactiveTrackColor: Colors.grey[800],
                                ),
                                const SizedBox(width: 8),
                                Text('Remember me',
                                    style: GoogleFonts.inter(color: Colors.white)),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.inter(color: Colors.yellow[700]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : Text(
                                    'Sign in',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        // Spacer works now because Column has a bounded minHeight
                        const Spacer(),

                        // Sign up option commented out - keeping only sign in
                        // Padding(
                        //   padding: const EdgeInsets.only(bottom: 30.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Text("Don't have an account? ",
                        //           style: GoogleFonts.inter(color: Colors.white)),
                        //       GestureDetector(
                        //         onTap: () => context.goNamed('signup'),
                        //         child: Text(
                        //           'Sign up now',
                        //           style: GoogleFonts.inter(
                        //             color: Colors.yellow[700],
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
