import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:routemaster/routemaster.dart';
import 'package:task_mate/core/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../auth/controller/auth_controller.dart';

final tabControllerProvider =
    StateNotifierProvider<TabControllerNotifier, TabController>((ref) {
  return TabControllerNotifier();
});

class TabControllerNotifier extends StateNotifier<TabController> {
  TabControllerNotifier() : super(TabController(length: 3, vsync: TestVSync()));

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}

class TestVSync extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'vsync');
  }
}

class IntroScreen1 extends ConsumerWidget {
  IntroScreen1({super.key});

  Future<void> signInWithGoogle(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle(context);
  }

  void signInWithApple(BuildContext context, WidgetRef ref) async {
    ref.read(authControllerProvider.notifier).isSignedInWithApple(context);
  }

  void notifications(BuildContext context) {
    Routemaster.of(context).push('/notifications');
  }

  bool hasError = false;

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

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  bool isSignup = true;

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
                  pageColor: Colors.black,
                  body: const Text('Welcome to Task Hub'),
                  title: RichText(
                    text: const TextSpan(
                      text: 'Task Hub',
                      style: TextStyle(
                        fontFamily: 'MyFont',
                        color: Colors.white,
                        fontSize: 34,
                      ),
                    ),
                    selectionColor: Colors.purple,
                  ),
                  mainImage: LottieBuilder.asset('assets/images/page1.json'),
                  titleTextStyle: const TextStyle(
                    fontFamily: 'MyFont',
                    color: Colors.white,
                    fontSize: 34,
                  ),
                  bodyTextStyle: const TextStyle(
                    fontFamily: 'MyFont',
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                PageViewModel(
                  pageColor: Colors.black,
                  body: const Text('Manage your task with Task Hub'),
                  mainImage: LottieBuilder.asset('assets/images/page2.json'),
                  titleTextStyle: const TextStyle(
                    fontFamily: 'MyFont',
                    color: Colors.white,
                    fontSize: 34,
                  ),
                  bodyTextStyle: const TextStyle(
                    fontFamily: 'MyFont',
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                PageViewModel(
                  pageColor: Colors.black,
                  body: const Text('Get started with Task Hub'),
                  mainImage:
                      LottieBuilder.asset('assets/images/task_animation.json'),
                  titleTextStyle: const TextStyle(
                    fontFamily: 'MyFont',
                    color: Colors.white,
                    fontSize: 34,
                  ),
                  bodyTextStyle: const TextStyle(
                    fontFamily: 'MyFont',
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                // hasError (condirion)
                PageViewModel(
                  pageColor: Colors.black,
                  body: Row(
                    children: [
                      LottieBuilder.asset('assets/images/page2.json'),
                      LottieBuilder.asset('assets/images/task_animation.json'),
                    ],
                  ),
                  mainImage: loginOptions(context, ref),
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
            ),
    );
  }

  loginOptions(BuildContext context, WidgetRef ref) {
    final tabController = ref.watch(tabControllerProvider);

    return MaterialApp(
      color: Colors.black,
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(24.0.widthPercent),
            child: AppBar(
              backgroundColor: Colors.black,
              bottom: TabBar(
                controller: tabController,
                tabs: [
                  Tab(
                      iconMargin: const EdgeInsets.only(bottom: 10),
                      icon: const Icon(FontAwesomeIcons.userPlus,
                          color: Colors.white),
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 3.9.widthPercent,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Tab(
                      icon: const Icon(FontAwesomeIcons.apple,
                          color: Colors.white),
                      child: Text(
                        'Sign up with Apple',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 3.9.widthPercent,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Tab(
                    icon: const Icon(FontAwesomeIcons.arrowRightToBracket,
                        color: Colors.white),
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 3.9.widthPercent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height -
                kToolbarHeight -
                kBottomNavigationBarHeight,
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 2.5,
                child: TabBarView(
                  controller: tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    buildSignUpView(context, ref),
                    buildSignUpAppleView(context, ref),
                    buildSignInView(context, ref),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSignUpView(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = TextEditingController();

    final TextEditingController passwordController = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0),
            ),
            labelText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: passwordController,
          decoration: const InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0),
            ),
            labelText: 'Enter your password',
            border: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }

            return null;
          },
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final authController = ref.read(authControllerProvider.notifier);

            try {
              if (emailController.text.isEmpty &&
                  passwordController.text.isEmpty) {
                Fluttertoast.showToast(
                  msg: 'Please enter email and password',
                  backgroundColor: Colors.red,
                );
              } else if (emailController.text.isEmpty) {
                Fluttertoast.showToast(
                  msg: 'Please enter email',
                  backgroundColor: Colors.red,
                );
              } else if (passwordController.text.isEmpty) {
                Fluttertoast.showToast(
                  msg: 'Please enter password',
                  backgroundColor: Colors.red,
                );
              } else if (!isValidEmail(emailController.text)) {
                Fluttertoast.showToast(
                  msg: 'Please enter valid email',
                  backgroundColor: Colors.red,
                );
              } else {
                // Set loading state
                authController.state = true;

                // Call the signInWithEmailAndPassword method from AuthController
                await authController.signUpWithEmailAndPassword(
                  emailController.text,
                  passwordController.text,
                );
              }
            } finally {
              // Reset loading state
              authController.state = false;
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: const Text('Sign up'),
        ),
      ],
    );
  }

  Widget buildSignUpAppleView(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          onPressed: () async {
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
      ],
    );
  }

  Widget buildSignInView(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = TextEditingController();

    final TextEditingController passwordController = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0),
            ),
            labelText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: passwordController,
          decoration: const InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0),
            ),
            labelText: 'Enter your password',
            border: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }

            return null;
          },
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final authController = ref.read(authControllerProvider.notifier);

            try {
              if (emailController.text.isEmpty &&
                  passwordController.text.isEmpty) {
                Fluttertoast.showToast(
                  msg: 'Please enter email and password',
                  backgroundColor: Colors.red,
                );
              } else if (emailController.text.isEmpty) {
                Fluttertoast.showToast(
                  msg: 'Please enter email',
                  backgroundColor: Colors.red,
                );
              } else if (passwordController.text.isEmpty) {
                Fluttertoast.showToast(
                  msg: 'Please enter password',
                  backgroundColor: Colors.red,
                );
              } else if (!isValidEmail(emailController.text)) {
                Fluttertoast.showToast(
                  msg: 'Please enter valid email',
                  backgroundColor: Colors.red,
                );
              } else {
                // Set loading state
                authController.state = true;

                // Call the signInWithEmailAndPassword method from AuthController
                await authController.signInWithEmailAndPassword(
                  emailController.text,
                  passwordController.text,
                  context,
                );
              }
            } finally {
              // Reset loading state
              authController.state = false;
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: const Text('Sign in'),
        ),
      ],
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
}
