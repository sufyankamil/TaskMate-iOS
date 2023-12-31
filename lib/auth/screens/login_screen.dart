import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          const Text('Login Screen'),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              // ref.read(authControllerProvider.notifier).signInWithGoogle();
            },
            child: const Text('Sign in with Google'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
