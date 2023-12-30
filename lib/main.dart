import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:routemaster/routemaster.dart';
import 'package:task_mate/firebase_options.dart';
import 'package:task_mate/home/screens/homepage.dart';
import 'package:task_mate/provider/failure.dart';
import 'package:task_mate/splash/screens/intro_screen_1.dart';

import 'auth/controller/auth_controller.dart';
import 'model/user_model.dart';
import 'router.dart';
import 'theme/pallete.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  //  debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (errorDetail) {
    FirebaseCrashlytics.instance.recordFlutterError(errorDetail);
  };

  // Pass all uncaught errors from the framework to Crashlytics.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? user;

  void getData(WidgetRef ref, User data) async {
    try {
      // Fetch user data from Firestore
      user = await ref
          .watch(authControllerProvider.notifier)
          .getUserData(data.uid)
          .first;

      // Check if user is not null before updating userProvider state
      if (user != null) {
        ref.read(userProvider.notifier).update((state) => user);
        setState(() {});
      } else {
        Fluttertoast.showToast(
          msg: 'User data is null',
          backgroundColor: Colors.red,
        );
        // Handle the case when user data is null, if needed
      }
    } catch (error) {
      // Handle other errors, if needed
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  // void getData(BuildContext context, WidgetRef ref, User data) async {
  //   try {
  //     UserModel user;

  //     // Check if the user signed in with Google
  //     if (data.providerData[0].providerId == 'google.com') {
  //       // Fetch user data from Firestore using the Google sign-in method
  //       user = await ref
  //           .watch(authControllerProvider.notifier)
  //           .getUserData(data.uid)
  //           .first;
  //     } else {
  //       // Fetch user data from Firestore using the email/password sign-up method
  //       Future.delayed(Duration.zero, () {
  //         // Delay the navigation until after the build phase
  //         navigatorKey.currentState!.pushReplacement(
  //           MaterialPageRoute(builder: (context) => const Home()),
  //         );
  //       });

  //       user = await ref
  //           .watch(authControllerProvider.notifier)
  //           .getUserData(data.uid)
  //           .first;
  //     }

  //     // Check if user is not null before updating userProvider state
  //     // ref.read(userProvider.notifier).update((state) => user);
  //     // setState(() {});
  //   } on Failure catch (failure) {
  //     Fluttertoast.showToast(
  //       msg: 'Account deletion failed: ${failure.message}',
  //       backgroundColor: Colors.red,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangesProvider).when(
          data: (data) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Task Hub',
            theme: ref.watch(themeNotifierProvider),
            routerDelegate: RoutemasterDelegate(
              navigatorKey: navigatorKey,
              routesBuilder: (context) {
                if (data != null) {
                  getData(ref, data);
                  if (user != null) {
                    return loggedInRoute;
                  }
                }
                return loggedOutRoute;
              },
            ),
            routeInformationParser: const RoutemasterParser(),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'This is unexpected :(',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        );
  }
}
