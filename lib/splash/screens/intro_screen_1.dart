import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:task_mate/core/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../auth/controller/auth_controller.dart';

class IntroScreen1 extends ConsumerWidget {
  const IntroScreen1({super.key});

  Future<void> signInWithGoogle(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle(context);
  }

  void signInWithApple(BuildContext context, WidgetRef ref) async {
    ref.read(authControllerProvider.notifier).isSignedInWithApple(context);
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
                      fontSize: 16,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w500,
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
            height: MediaQuery.of(context).size.height - 60.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // showChooseAccountModal(context);
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Task Hub',
                      style: TextStyle(
                        fontFamily: 'MyFont',
                        fontSize: 7.0.widthPercent,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Please select an account to continue',
                    style: TextStyle(
                      fontFamily: 'MyFont',
                      fontSize: 5.0.widthPercent,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    openCupertinoSheetForLogin(context, ref);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        FontAwesomeIcons.solidEnvelope,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sign up with Email',
                        style: TextStyle(
                          color: Colors.black,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
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
                Padding(
                  padding: EdgeInsets.all(3.0.widthPercent),
                  child: const Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Already have an account?',
                  style: TextStyle(
                    fontSize: 3.0.widthPercent,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                loginProcess(context, ref),
                const Spacer(),
                privayPolicy(),
                const SizedBox(height: 20),
                complaince(),
                const SizedBox(height: 20),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  void openCupertinoSheetForLogin(BuildContext context, WidgetRef ref) {
    TextEditingController email = TextEditingController();

    TextEditingController password = TextEditingController();

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return CupertinoPopupSurface(
          key: _formKey,
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // showChooseAccountModal(context);
                          if (_formKey.currentContext != null) {
                            Navigator.pop(_formKey.currentContext!);
                          }
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enter email and password',
                      style: TextStyle(
                        fontFamily: 'MyFont',
                        fontSize: 7.0.widthPercent,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Text(
                  'to continue',
                  style: TextStyle(
                    fontFamily: 'MyFont',
                    fontSize: 7.0.widthPercent,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                emailTextField(email, context),
                const SizedBox(height: 10),
                passwordTextField(password),
                const SizedBox(height: 20),
                createAccountWithEmailButton(ref, email, password, _formKey),
              ],
            ),
          ),
        );
      },
    );
  }

  ElevatedButton createAccountWithEmailButton(WidgetRef ref, TextEditingController email, TextEditingController password, GlobalKey<FormState> _formKey) {
    return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                onPressed: () async {
                  final authController =
                      ref.read(authControllerProvider.notifier);

                  try {
                    if (email.text.isEmpty || password.text.isEmpty) {
                      Fluttertoast.showToast(msg: 'Please fill all fields');
                      return;
                    } else if (!isValidEmail(email.text)) {
                      Fluttertoast.showToast(msg: 'Please enter valid email');
                      return;
                    } else if (password.text.length < 6) {
                      Fluttertoast.showToast(
                          msg: 'Password must be at least 6 characters');
                      return;
                    } else {
                      // Set loading state
                      authController.state = true;

                      await authController.signUpWithEmailAndPassword(
                        email.text,
                        password.text,
                      );
                    }
                    if (_formKey.currentContext != null) {
                      Navigator.pop(_formKey.currentContext!);
                    }
                  } finally {
                    // Reset loading state
                    authController.state = false;
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      FontAwesomeIcons.solidEnvelope,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 5.0.widthPercent,
                      ),
                    ),
                  ],
                ),
              );
  }

  Padding passwordTextField(TextEditingController password) {
    return Padding(
                padding: EdgeInsets.only(
                    left: 8.0.widthPercent,
                    right: 8.0.widthPercent,
                    top: 8.0.widthPercent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 2.5.widthPercent),
                      child: Text(
                        'Enter your password',
                        style: TextStyle(
                          fontFamily: 'MyFont',
                          fontSize: 3.0.widthPercent,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    CupertinoTextFormFieldRow(
                      controller: password,
                      placeholder: 'Password',
                      placeholderStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      padding: const EdgeInsets.all(10),
                      obscureText: true,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              );
  }

  Padding emailTextField(TextEditingController email, BuildContext context) {
    return Padding(
                padding: EdgeInsets.only(
                    left: 8.0.widthPercent,
                    right: 8.0.widthPercent,
                    top: 8.0.widthPercent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 2.5.widthPercent),
                      child: Text(
                        'Enter email address',
                        style: TextStyle(
                          fontFamily: 'MyFont',
                          fontSize: 3.0.widthPercent,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    CupertinoTextFormFieldRow(
                      controller: email,
                      placeholder: 'Email',
                      placeholderStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        FocusScope.of(context).nextFocus();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              );
  }

  bool isValidEmail(String email) {
    // Define a regular expression pattern for a simple email validation
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );

    // Test if the email matches the pattern
    return emailRegex.hasMatch(email);
  }

  Text complaince() {
    return Text(
      '© 2023 Task Hub',
      style: TextStyle(
        fontSize: 3.0.widthPercent,
        color: Colors.black,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  GestureDetector privayPolicy() {
    return GestureDetector(
      onTap: () async {
        const url =
            'https://www.freeprivacypolicy.com/live/37e19f74-f46a-43d1-a048-5264a1ffd46a'; // Replace with your actual URL
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          Fluttertoast.showToast(
            msg: 'Something went wrong',
            backgroundColor: Colors.red,
          );
        }
      },
      child: Text(
        'By continuing, you agree to our Terms of Service and Privacy Policy',
        style: TextStyle(
          fontSize: 3.0.widthPercent,
          color: Colors.black,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Row loginProcess(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            print('Sign In with google');
          },
          icon: const Icon(
            FontAwesomeIcons.google,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: () {
            signInWithApple(context, ref);
            print('Sign In with apple');
          },
          icon: const Icon(
            FontAwesomeIcons.apple,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
