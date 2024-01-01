import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:routemaster/routemaster.dart';
import 'package:task_mate/core/utils/extensions.dart';
import 'package:task_mate/provider/failure.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/controller/auth_controller.dart';
import '../auth/repository/auth_repository.dart';
import '../auth/screens/login_screen.dart';
import '../common/constants.dart';
import '../theme/pallete.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void navigateToProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/profile/$uid');
  }

  Future<void> logout(WidgetRef ref, BuildContext context) async {
    ref.read(authControllerProvider.notifier).logout();

    // Pop all routes until reaching the root
    Navigator.popUntil(context, (route) => route.isFirst);

    // Push the new route after popUntil is completed
    Future.delayed(Duration.zero, () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    });
  }

  void pushToSubscribe(BuildContext context) {
    Routemaster.of(context).push('/subscribe');
  }

  void pushToAgent(BuildContext context) {
    Routemaster.of(context).push('/support');
  }

  void futurePremium(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(Constants.upgradeToPremium),
          content: const Text('This feature is coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void showHelp(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: Constants.mailScheme,
      path: Constants.mailPath,
      queryParameters: {'subject': Constants.mailSubject},
    );

    final String urlString = emailLaunchUri.toString();

    if (await canLaunch(urlString)) {
      await launch(urlString);
    } else {
      // If the URL can't be launched, handle the error
      if (context.mounted) {
        Theme.of(context).platform == TargetPlatform.android
            ? showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(Constants.mailError),
                  content: const Text(Constants.mailErrorContent),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(Constants.ok),
                    ),
                  ],
                ),
              )
            : showDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text(Constants.mailError),
                  content: const Text(Constants.mailErrorContent),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(Constants.ok),
                    ),
                  ],
                ),
              );
      }
    }
  }

  void showSuggestionsDialog(BuildContext context) {
    Theme.of(context).platform == TargetPlatform.android
        ? showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(Constants.suggestions),
              content: const Text(Constants.suggestionsContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(Constants.ok),
                ),
              ],
            ),
          )
        : showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text(Constants.suggestions),
              content: const Text(Constants.suggestionsContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(Constants.ok),
                ),
              ],
            ),
          );
  }

  Future<void> logOUT(WidgetRef ref, BuildContext context) async {
    try {
      await ref.read(authRepositoryProvider).logoutWithEmailAndPassword();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      // Handle logout error
      Fluttertoast.showToast(
        msg: 'Logout error: $e',
        backgroundColor: Colors.red,
        timeInSecForIosWeb: 5,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user == null) return const CircularProgressIndicator.adaptive();

    final themeProvider = ref.watch(themeNotifierProvider.notifier);

    bool isDark = themeProvider.isDark;

    void toggleTheme(WidgetRef ref) {
      themeProvider.toggleTheme();
    }

    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppBar(
                title: const Text('My Profile'),
                automaticallyImplyLeading: true,
                backgroundColor:
                    isDark ? Colors.transparent : Colors.transparent,
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  user.photoUrl,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Karma: ${user.karma}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.subscriptions, color: Colors.red),
                title: const Text(Constants.upgradeToPremium,
                    style: TextStyle(
                      color: Colors.red,
                    )),
                onTap: () {
                  futurePremium(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_align_center),
                title: const Text(Constants.suggestions),
                onTap: () {
                  showSuggestionsDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shield_moon_outlined),
                title: const Text(Constants.switchTheme),
                onTap: () {
                  toggleTheme(ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text(Constants.help),
                onTap: () {
                  showHelp(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text(Constants.deleteAccount),
                onTap: () {
                  deleteAccount(context, ref);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // logOUT(ref, context);
                  logout(ref, context);
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Pallete.redColor),
                child: Text(
                  Constants.logout,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> deleteAccount(BuildContext context, WidgetRef ref) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(Constants.deleteAccount),
          content: const Text(Constants.deleteAccountContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(Constants.cancel),
            ),
            TextButton(
              onPressed: () {
                confirmDeleteAccount(context, ref);
              },
              child: const Text(Constants.delete,
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showPasswordInputDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();

    return await showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Enter Password'),
          content: CupertinoTextField(
            controller: passwordController,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            placeholder: 'Password',
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (password) {
              Navigator.pop(context, password);
            },
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context, passwordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  void confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    TextEditingController confirmationController = TextEditingController();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return CupertinoPopupSurface(
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: 200.0.widthPercent,
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
                    Constants.deleteAccount,
                    style: TextStyle(
                      fontFamily: 'MyFont',
                      fontSize: 5.0.widthPercent,
                      color: Colors.red,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.all(3.0.widthPercent),
                  child: const Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(
                    Constants.deletingContent,
                    style: TextStyle(
                      fontFamily: 'MyFont',
                      fontSize: 3.0.widthPercent,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w500,
                    ),
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(
                    Constants.deleteContent1,
                    style: TextStyle(
                      fontFamily: 'MyFont',
                      fontSize: 3.0.widthPercent,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w500,
                    ),
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(
                    Constants.deleteContent2,
                    style: TextStyle(
                      fontFamily: 'MyFont',
                      fontSize: 3.0.widthPercent,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(
                    Constants.deleteContent3,
                    style: TextStyle(
                      fontFamily: 'MyFont',
                      fontSize: 3.0.widthPercent,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  Constants.deleteContent4,
                  style: TextStyle(
                    fontFamily: 'MyFont',
                    fontSize: 3.0.widthPercent,
                    color: Colors.red,
                    decoration: TextDecoration.none,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(
                    Constants.confirmation,
                    style: TextStyle(
                      fontFamily: 'MyFont',
                      fontSize: 4.0.widthPercent,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CupertinoTextField(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    controller: confirmationController,
                    placeholder: 'Type "CONFIRM" to proceed',
                    placeholderStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    padding: const EdgeInsets.all(12),
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    obscureText: false,
                    textCapitalization: TextCapitalization.none,
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoButton(
                  color: Colors.red,
                  onPressed: () async {
                    final authController =
                        ref.read(authControllerProvider.notifier);

                    try {
                      // Check if the entered text is "CONFIRM" to proceed with deletion
                      if (confirmationController.text == 'CONFIRM') {
                        final currentUser = await authController
                            .authStateChanges
                            .firstWhere((user) => user != null);

                        final isAppleSignIn = currentUser!.providerData.any(
                            (provider) => provider.providerId == 'apple.com');

                        final email = currentUser.email ?? '';

                        if (isAppleSignIn) {
                          if (context.mounted) {
                            await authController.deleteAccountWithApple(
                              context,
                              currentUser.uid,
                              email,
                            );
                          }
                          Routemaster.of(context).replace('/');
                        } else {
                          // Show the password input dialog
                          final password =
                              await _showPasswordInputDialog(context);

                          if (password != null) {
                            // Call the deleteAccount method with user details
                            await authController.deleteAccount(
                              currentUser.uid,
                              email,
                              password,
                            );

                            Routemaster.of(context).replace('/');
                          } else {
                            if (context.mounted) {
                              showCupertinoDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    title: const Text('Deletion Error'),
                                    content: const Text(
                                        'Please enter your password to proceed.'),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        }
                      }
                    } on Failure catch (failure) {
                      // Handle the failure, show error message to the user
                      if (failure.message == 'User is null') {
                        if (context.mounted) {
                          showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: const Text('Deletion Error'),
                                content: const Text(
                                    'The user is null, please sign in again.'),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } else if (context.mounted) {
                        showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text('Deletion Error'),
                              content: const Text('The password is invalid'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: const Text('Confirm Deletion'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
