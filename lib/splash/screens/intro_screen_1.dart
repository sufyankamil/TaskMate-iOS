import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:lottie/lottie.dart';

import '../../auth/controller/auth_controller.dart';

class IntroScreen1 extends ConsumerWidget {
  const IntroScreen1({super.key});

  void signInWithGoogle(BuildContext context, WidgetRef ref) async {
    ref.read(authControllerProvider.notifier).signInWithGoogle(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: IntroViewsFlutter(
        [
          PageViewModel(
            pageColor: Colors.white,
            body: const Text('Welcome to Task Hub'),
            title: RichText(
              text: const TextSpan(
                text: 'Task Hub',
                style: TextStyle(
                  fontFamily: 'MyFont',
                  color: Colors.black,
                  fontSize: 34,
                ),
              ),
              selectionColor: Colors.purple,
            ),
            mainImage: LottieBuilder.asset('assets/images/page1.json'),
            titleTextStyle: const TextStyle(
              fontFamily: 'MyFont',
              color: Colors.black,
              fontSize: 34,
            ),
            bodyTextStyle: const TextStyle(
              fontFamily: 'MyFont',
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          PageViewModel(
            pageColor: Colors.white,
            body: const Text('Manage your task with Task Hub'),
            mainImage: LottieBuilder.asset('assets/images/page2.json'),
            titleTextStyle: const TextStyle(
              fontFamily: 'MyFont',
              color: Colors.black,
              fontSize: 34,
            ),
            bodyTextStyle: const TextStyle(
              fontFamily: 'MyFont',
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          PageViewModel(
            pageColor: Colors.white,
            body: const Text('Get started with Task Hub'),
            mainImage: LottieBuilder.asset('assets/images/task_animation.json'),
            titleTextStyle: const TextStyle(
              fontFamily: 'MyFont',
              color: Colors.black,
              fontSize: 34,
            ),
            bodyTextStyle: const TextStyle(
              fontFamily: 'MyFont',
              color: Colors.black,
              fontSize: 24,
            ),
          ),
        ],
        showNextButton: true,
        showSkipButton: true,
        skipText: const Text(
          'Skip',
          style: TextStyle(
            fontFamily: 'MyFont',
            color: Colors.black,
          ),
        ),
        nextText: const Text(
          'Next',
          style: TextStyle(
            fontFamily: 'MyFont',
            color: Colors.black,
          ),
        ),
        doneText: TextButton(
          onPressed: () => signInWithGoogle(context, ref),
          child: const Text(
            'Done',
            style: TextStyle(
              fontFamily: 'MyFont',
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
