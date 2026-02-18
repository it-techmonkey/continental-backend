import 'package:continental/feature/actionable/customerDetailScreen.dart';
import 'package:continental/feature/actionable/edit_payment_screen.dart';
import 'package:continental/feature/auth/logIn.dart';
// import 'package:continental/feature/auth/signUp.dart'; // Commented out - sign up disabled
import 'package:continental/feature/menu/payments/payment_details_screen.dart';
import 'package:continental/feature/menu/payments/payment_list_screen.dart';
import 'package:continental/feature/menu/profileScreen.dart';
import 'package:continental/feature/onBoarding/onboarding_screen.dart';
import 'package:continental/feature/onBoarding/splashScreen.dart';
import 'package:continental/feature/portfolio/addProperty/addPropertyScreen.dart';
import 'package:continental/widget/bottonNavBar.dart';
import 'package:continental/providers/auth_state_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isLoginPage = state.fullPath == '/login';
      final isOnboarding = state.fullPath == '/onboarding';
      final isSplash = state.fullPath == '/';
      
      // Allow access to splash, onboarding, and login without auth
      if (isSplash || isOnboarding || isLoginPage) {
        return null;
      }
      
      // Redirect to login if not authenticated
      if (!isAuthenticated) {
        return '/login';
      }
      
      return null;
    },
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      // Sign up route commented out - keeping only sign in option
      // GoRoute(
      //   path: '/signup',
      //   name: 'signup',
      //   builder: (BuildContext context, GoRouterState state) {
      //     return SignUpScreen();
      //   },
      // ),
      GoRoute(
        path: '/bottomnav',
        name: 'bottomnav',
        builder: (BuildContext context, GoRouterState state) {
          return BottomNav();
        },
        routes: [
          GoRoute(
            path: 'details/:itemId', // Path parameter for the item ID
            name: 'details',
            builder: (BuildContext context, GoRouterState state) {
              // Extract the itemId from the route path
              final itemId = state.pathParameters['itemId']!;
              return CustomerDetailsScreen(itemId: itemId);
            },
            routes: [
              GoRoute(
                path: 'edit-payment',
                name: 'edit-payment',
                builder: (BuildContext context, GoRouterState state) {
                  final params = state.uri.queryParameters;
                  final pathParams = state.pathParameters;
                  return EditPaymentScreen(
                    paymentId: int.parse(params['paymentId']!),
                    amount: num.parse(params['amount']!),
                    status: params['status']!,
                    currentProofUrl: params['proofUrl'],
                    occupantRecordId: int.tryParse(pathParams['itemId'] ?? '0') ?? 0,
                    modeOfPayment: params['modeOfPayment'],
                    paymentDate: params['paymentDate'],
                    propertyType: params['propertyType'],
                  );
                },
              ),
              GoRoute(
                path: 'edit-property',
                name: 'edit-property',
                builder: (BuildContext context, GoRouterState state) {
                  final pathParams = state.pathParameters;
                  final occupantRecordId = int.tryParse(pathParams['itemId'] ?? '0') ?? 0;
                  return AddPropertyScreen(occupantRecordId: occupantRecordId);
                },
              ),
            ],
          ),

          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (BuildContext context, GoRouterState state) {
              return const ProfileScreen();
            },
          ),

          GoRoute(
            path: 'payments',
            name: 'payments',
            builder: (BuildContext context, GoRouterState state) {
              return const PaymentsScreen();
            },
            routes: [
              GoRoute(
                path: 'details/:paymentId', // Path parameter
                name: 'payment-details',
                builder: (BuildContext context, GoRouterState state) {
                  final paymentId = state.pathParameters['paymentId']!;
                  return PaymentDetailsScreen(paymentId: paymentId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/add-property',
            name: 'add-property',
            builder: (BuildContext context, GoRouterState state) {
              return const AddPropertyScreen();
            },
          ),
        ],
      ),
      //  GoRoute(
      //     path: '/profile',
      //     name: 'profile',
      //     builder: (BuildContext context, GoRouterState state) {
      //       return const ProfileScreen();
      //     },
      //   ),
    ],
  );
});
