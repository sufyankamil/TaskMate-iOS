import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/firebase_options.dart';

import 'auth/controller/auth_controller.dart';
import 'model/user_model.dart';
import 'router.dart';
import 'theme/pallete.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load(fileName: ".env");

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

  late ThemeData _themeData;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeMode = prefs.getString('theme_mode') ?? 'light';
    setState(() {
      _themeData = _getThemeData(themeMode);
    });
  }

  ThemeData _getThemeData(String themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeData.light();
      case 'dark':
        return ThemeData.dark();
      default:
        return ThemeData.from(colorScheme: const ColorScheme.light());
    }
  }

  void _setTheme(String mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme_mode', mode);
    setState(() {
      _themeData = _getThemeData(mode);
    });
  }

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
      if (kDebugMode) {
        print('Error from Main thread: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangesProvider).when(
          data: (data) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Task Hub',
            themeMode: ThemeMode.system,
            theme: ref.watch(themeNotifierProvider),
            routerDelegate: RoutemasterDelegate(
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
