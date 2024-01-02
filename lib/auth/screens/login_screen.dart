import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:task_mate/core/utils/extensions.dart';
import 'package:task_mate/home/screens/homepage.dart';

import '../controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: const TextSpan(
                text: 'Task Hub',
                style: TextStyle(
                  fontFamily: 'MyFont',
                  color: Colors.black,
                  fontSize: 34,
                ),
              ),
              selectionColor: Colors.purple,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Center(child: LottieBuilder.asset('assets/images/page1.json')),
            const SizedBox(height: 20),
            Text(
              'Welcome to Task Hub',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'MyFont',
                color: Colors.black,
                fontSize: 7.0.widthPercent,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NextScreen(),
            ),
          );
        },
        child: const Icon(FontAwesomeIcons.arrowRight),
      ),
    );
  }
}

class NextScreen extends ConsumerStatefulWidget {
  const NextScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NextScreenState();
}

class _NextScreenState extends ConsumerState<NextScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: LottieBuilder.asset('assets/images/page2.json')),
            const SizedBox(height: 25),
            Text(
              'Manage your task with Task Hub',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'MyFont',
                color: Colors.black,
                fontSize: 7.0.widthPercent,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginBranch(),
            ),
          );
        },
        child: const Icon(FontAwesomeIcons.arrowRight),
      ),
    );
  }
}

class LoginBranch extends ConsumerStatefulWidget {
  const LoginBranch({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginBranchState();
}

class _LoginBranchState extends ConsumerState<LoginBranch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child:
                    LottieBuilder.asset('assets/images/task_animation.json')),
            const SizedBox(height: 25),
            Text(
              'Manage your task with Task Hub',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'MyFont',
                color: Colors.black,
                fontSize: 7.0.widthPercent,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FInalLogin(),
            ),
          );
        },
        child: const Icon(FontAwesomeIcons.arrowRight),
      ),
    );
  }
}

class FInalLogin extends ConsumerStatefulWidget {
  const FInalLogin({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FInalLoginState();
}

class _FInalLoginState extends ConsumerState<FInalLogin> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator.adaptive(
                  semanticsLabel: 'Please wait...',
                ),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    buildSignUpView(context, ref),
                  ],
                ),
              ),
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

  Widget buildSignUpView(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    final TextEditingController emailController = TextEditingController();

    final TextEditingController passwordController = TextEditingController();

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Create account',
            style: TextStyle(
              fontFamily: 'MyFont',
              color: Colors.white,
              fontSize: 7.0.widthPercent,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
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
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
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
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                // Validation passed, continue with sign-up logic
                final authController =
                    ref.read(authControllerProvider.notifier);

                try {
                  // Set loading state
                  authController.state = true;

                  // Call the signUpWithEmailAndPassword method from AuthController
                  final result =
                      await authController.signUpWithEmailAndPassword(
                    emailController.text,
                    passwordController.text,
                  );
                  print(result);
                  if (result) {
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Home(),
                        ),
                      );
                    }
                  } else {}
                } finally {
                  // Reset loading state
                  authController.state = false;
                }
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: const Text('Sign up'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '────   or   ────',
                style: TextStyle(
                  fontFamily: 'MyFont',
                  color: Colors.white,
                  fontSize: 5.0.widthPercent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildSignUpAppleView(context, ref),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(
                  fontFamily: 'MyFont',
                  color: Colors.white,
                  fontSize: 5.0.widthPercent,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SigninPage(),
                    ),
                  );
                },
                child: Text(
                  'Sign in',
                  style: TextStyle(
                    fontFamily: 'MyFont',
                    color: Colors.blue,
                    fontSize: 5.0.widthPercent,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
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
            backgroundColor: Colors.white,
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
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const Home(), // Replace HomeScreen with your actual home screen widget
                  ),
                );
              }
            } catch (e) {
              print(e);
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
                color: Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                'Sign up with Apple',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 5.0.widthPercent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SigninPage extends ConsumerStatefulWidget {
  const SigninPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SigninPageState();
}

class _SigninPageState extends ConsumerState<SigninPage> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator.adaptive(
                  semanticsLabel: 'Please wait...',
                ),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    buildSignInView(context, ref),
                  ],
                ),
              ),
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

  Widget buildSignUpAppleView(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        IconButton(
          onPressed: () async {
            try {
              // Set loading state
              authController.state = true;

              // Call the signInWithApple method from AuthController
              await authController.signInWithApple(context);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home(),
                ),
              );
            } finally {
              // Reset loading state
              authController.state = false;
            }
          },
          icon: Icon(
            FontAwesomeIcons.apple,
            color: Colors.white,
            size: 10.0.widthPercent,
          ),
        ),
      ],
    );
  }

  Widget buildSignInView(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    final TextEditingController emailController = TextEditingController();

    final TextEditingController passwordController = TextEditingController();

    final TextEditingController resetPasswordController =
        TextEditingController();

    Future<void> handleResetPassword(String email, WidgetRef ref) async {
      final authController = ref.read(authControllerProvider.notifier);

      try {
        // Set loading state
        authController.state = true;

        // Call the handleResetPassword method from AuthController
        await authController.sendPasswordResetEmail(email);
      } finally {
        // Reset loading state
        authController.state = false;
      }
    }

    void handeForgtPassword(BuildContext context) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email to reset the password.'),
              const SizedBox(height: 10),
              CupertinoTextFormFieldRow(
                controller: resetPasswordController,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border(
                    bottom: BorderSide(
                      width: 0,
                      color: CupertinoColors.inactiveGray,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                prefix: const Text('Email: '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                await handleResetPassword(resetPasswordController.text, ref);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Reset Password'),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sign in',
            style: TextStyle(
              fontFamily: 'MyFont',
              color: Colors.white,
              fontSize: 7.0.widthPercent,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
                labelText: 'Enter your email',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.white),
                contentPadding: EdgeInsets.all(10),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
                labelText: 'Enter your password',
                labelStyle: TextStyle(color: Colors.white),
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
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              Text(
                'Forgot password?',
                style: TextStyle(
                  fontFamily: 'MyFont',
                  color: Colors.white,
                  fontSize: 4.0.widthPercent,
                ),
              ),
              TextButton(
                onPressed: () {
                  // handlePasswordReset(context);
                  handeForgtPassword(context);
                },
                child: Text(
                  'Reset',
                  style: TextStyle(
                    fontFamily: 'MyFont',
                    color: Colors.red,
                    fontSize: 4.0.widthPercent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                // Validation passed, continue with sign-up logic
                final authController =
                    ref.read(authControllerProvider.notifier);

                try {
                  // Set loading state
                  authController.state = true;

                  // Call the signUpWithEmailAndPassword method from AuthController
                  final result =
                      await authController.signInWithEmailAndPassword(
                    emailController.text,
                    passwordController.text,
                    context,
                  );

                  print(result);

                  if (result) {
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Home(),
                        ),
                      );
                    }
                  } else {}
                } finally {
                  // Reset loading state
                  authController.state = false;
                }
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: const Text('Sign in'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '────   or   ────',
                style: TextStyle(
                  fontFamily: 'MyFont',
                  color: Colors.white,
                  fontSize: 5.0.widthPercent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildSignUpAppleView(context, ref),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account?',
                style: TextStyle(
                  fontFamily: 'MyFont',
                  color: Colors.white,
                  fontSize: 5.0.widthPercent,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FInalLogin(),
                    ),
                  );
                },
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    fontFamily: 'MyFont',
                    color: Colors.blue,
                    fontSize: 5.0.widthPercent,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
