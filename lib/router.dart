import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:task_mate/splash/screens/intro_screen_1.dart';

import 'home/screens/homepage.dart';
import 'profile/user_profile.dart';
import 'report/screens/show_report.dart';
import 'splash/screens/splash_screen.dart';
import 'task/screen/add_sub_task.dart';
import 'task/screen/add_task.dart';
import 'task/screen/completed_task.dart';
import 'task/screen/detailed_task.dart';

final loggedInRoute = RouteMap(
  routes: {
    '/': (route) => const MaterialPage(
          child: Home(),
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
  },
);

// logout route
final loggedOutRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(
          child: IntroScreen1(),
        ),
  },
);
