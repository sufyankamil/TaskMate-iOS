import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../../auth/controller/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSplashScreen(
        splash: SizedBox(
          height: 20.0.widthPercent,
          width: 20.0.widthPercent,
          child: LottieBuilder.asset(
            'assets/images/page2.json',
          ),
        ),
        nextScreen: const NextScreen(),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}

class NextScreen extends ConsumerWidget {
  const NextScreen({super.key});

  void signInWithGoogle(BuildContext context, WidgetRef ref) async {
    ref.read(authControllerProvider.notifier).signInWithGoogle(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'Welcome to Task Mate',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.0.widthPercent,
                        vertical: 3.0.widthPercent,
                      ),
                      child: Text(
                        'Manage your task easily',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.0.textPercentage,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => signInWithGoogle(context, ref),
                      child: const Text('Sign in with Google'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
