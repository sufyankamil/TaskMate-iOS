import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import 'home/screens/homepage.dart';
import 'splash/screens/splash_screen.dart';

final loggedInRoute = RouteMap(
  routes: {
    '/': (route) => const MaterialPage(
          child: Home(),
        ),
  },
);

// logout route
final loggedOutRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(
          child: SplashScreen(),
        ),
  },
);
