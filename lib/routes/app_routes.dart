import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/features/auth/screens/new_password_screen.dart';
import 'package:market_jango/features/auth/screens/verification_screen.dart';
import 'package:market_jango/features/buyer/screens/Home%20screen.dart';

import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: BuyerHomeScreen.routeName,
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Error: ${state.error } '),
    ),
  ),
  routes: [
    GoRoute(
      path: LoginScreen.routeName,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: ForgotPasswordScreen.routeName,
       name: 'forgot_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: VerificationScreen.routeName,
      name: 'verification',
      builder: (context, state) => const VerificationScreen(),
    ),
    GoRoute(
      path: NewPasswordScreen.routeName,
      name: 'new_password',
      builder: (context, state) => const NewPasswordScreen(),
    ),
    GoRoute(
      path: BuyerHomeScreen.routeName,
      name: 'buyer_home',
      builder: (context, state) => const BuyerHomeScreen(),
    ),

  ],
);
