import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../../auth/controller/auth_controller.dart';

class IntroScreen1 extends ConsumerWidget {
  const IntroScreen1({super.key});

  Future<void> signInWithGoogle(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle(context);
  }

  Future showCanelText(BuildContext context) {
    return Future.delayed(const Duration(microseconds: 1), () {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to cancel?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);

    return CupertinoPageScaffold(
      child: isLoading
          ? Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator.adaptive(
                  semanticsLabel: 'Please wait...',
                ),
              ),
            )
          : IntroViewsFlutter(
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
                  mainImage:
                      LottieBuilder.asset('assets/images/task_animation.json'),
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
              showSkipButton: false,
              nextText: const Text(
                'Next',
                style: TextStyle(
                  fontFamily: 'MyFont',
                  color: Colors.black,
                ),
              ),
              doneText: TextButton(
                onPressed: () {
                  openCupertinoSheet(context, ref);
                },
                child: const Text(
                  'Let\'s Get Started',
                  style: TextStyle(
                    fontFamily: 'MyFont',
                    color: Colors.green,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
    );
  }

  void showChooseAccountModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return CupertinoPopupSurface(
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Please choose an account to continue your journey to add a task.',
                    style: TextStyle(
                      fontFamily: 'MyFont',
                      fontSize: 16,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: CupertinoColors.systemRed),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void openCupertinoSheet(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return CupertinoPopupSurface(
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Please select an account to continue',
                    style: TextStyle(
                      fontFamily: 'MyFont',
                      fontSize: 20,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await signInWithGoogle(context, ref);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        FontAwesomeIcons.google,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sign In with Google',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 5.0.widthPercent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);

                    final authController =
                        ref.read(authControllerProvider.notifier);

                    try {
                      // Set loading state
                      authController.state = true;

                      // Call the signInWithApple method from AuthController
                      await authController.signInWithApple(context);
                    } finally {
                      // Reset loading state
                      authController.state = false;
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        FontAwesomeIcons.apple,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sign up with Apple',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 5.0.widthPercent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoButton(
                  onPressed: () {
                    showChooseAccountModal(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: CupertinoColors.systemRed),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
