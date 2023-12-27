import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/controller/auth_controller.dart';
import '../common/constants.dart';
import '../theme/pallete.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void navigateToProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/profile/$uid');
  }

  void logout(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).logout();
    Routemaster.of(context).replace('/');
  }

  void pushToSubscribe(BuildContext context) {
    Routemaster.of(context).push('/subscribe');
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user == null) return const CircularProgressIndicator.adaptive();

    final themeProvider = ref.watch(themeNotifierProvider.notifier);

    bool isDark = themeProvider.isDark;

    void toggleTheme(WidgetRef ref) {
      ref.read(themeNotifierProvider.notifier).toggleTheme();
     
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
                leading: const Icon(Icons.workspace_premium, color: Colors.red),
                title: const Text(Constants.upgradeToPremium,
                    style: TextStyle(
                      color: Colors.red,
                    )),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text(Constants.myProfile),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.format_align_center),
                title: const Text(Constants.suggestions),
                onTap: () {
                  showSuggestionsDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text(Constants.settings),
                onTap: () {},
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
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
}
