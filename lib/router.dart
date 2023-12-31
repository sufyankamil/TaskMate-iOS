import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:task_mate/auth/screens/login_screen.dart';
import 'package:task_mate/splash/screens/intro_screen_1.dart';

import 'home/screens/homepage.dart';
import 'profile/user_profile.dart';
import 'report/screens/show_report.dart';
import 'support/support_chat.dart';
import 'task/screen/add_sub_task.dart';
import 'task/screen/add_task.dart';
import 'task/screen/completed_task.dart';
import 'task/screen/detailed_task.dart';

final loggedInRoute = RouteMap(
  routes: {
    '/': (route) => const MaterialPage(
          child: Home(),
        ),
    '/login': (route) => const MaterialPage(
          child: LoginScreen(),
        ),
    '/user-profile': (route) => const MaterialPage(
          child: ProfileDrawer(),
        ),
    '/add-task': (route) => const MaterialPage(
          child: AddTask(),
        ),
    'show-report-task': (route) => const MaterialPage(
          child: ShowReport(),
        ),
    '/task-detail/:taskId': (route) => MaterialPage(
          child: DetailedPage(
            taskId: route.pathParameters['taskId']!,
          ),
        ),
    '/sub-task/:taskId': (route) => MaterialPage(
          child: SubTask(
            taskId: route.pathParameters['taskId']!,
          ),
        ),
    '/completed-task/:taskId': (route) => MaterialPage(
          child: CompletedTask(
            taskId: route.pathParameters['taskId']!,
          ),
        ),
    '/support': (route) => const MaterialPage(
          child: SupportPage(),
        ),
  },
);

// logout route
final loggedOutRoute = RouteMap(
  routes: {
    '/': (_) => MaterialPage(
          child: IntroScreen1(),
        ),
  },
);
