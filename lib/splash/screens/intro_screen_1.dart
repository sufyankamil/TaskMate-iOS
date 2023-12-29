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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      child: IntroViewsFlutter([
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
          doneText: CupertinoButton(
            color: Colors.white,
            onPressed: () {
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
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sign In with Google',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 5.0.widthPercent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
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
                          CupertinoButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancel',
                              style:
                                  TextStyle(color: CupertinoColors.systemRed),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(),
          )),
    );
  }
}
