import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:routemaster/routemaster.dart';

import '../../auth/controller/auth_controller.dart';
import '../../auth/repository/auth_repository.dart';
import '../../common/constants.dart';
import '../../task/controller/task_controller.dart';
import '../../theme/pallete.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  int _page = 0;

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    int notificationCount = 0;

    final user = ref.watch(userProvider);

    final currentTheme = ref.watch(themeNotifierProvider);

    void navigateToProfile(BuildContext context, String uid) {
      Routemaster.of(context).push('/user-profile');
    }

    final usersTask = ref.watch(userTaskProvider);

    final usersData = usersTask.when(
      data: (data) => data,
      loading: () =>
          null, // Return null for loading state or handle it as needed
      error: (e, s) =>
          null, // Return null for error state or handle it as needed
    );

    if (usersData != null) {
      // save the number of task in the notificationCount variable
      notificationCount = usersData.length;
    } else {
      // Handle loading or error state here if necessary
      if (kDebugMode) {
        print('Loading or Error State');
      }
    }

    Future<void> refreshUserData() async {
      final authRepository = ref.read(authRepositoryProvider);

      try {
        ref.refresh(userTaskProvider);
        await authRepository.refreshUserData((user) {
          ref.read(userProvider.notifier).update((state) => user);
        });
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }

    bool setRefresh = false;

    return MaterialApp(
      theme: currentTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text(
            'TaskMate',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // if user is not null, then show logout button else show login button
            if (user != null)
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Fluttertoast.showToast(
                        msg: 'Notifications coming soon!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: currentTheme.primaryColor,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    },
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications),
                        if (notificationCount > 0)
                          Positioned(
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6),
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                '$notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        navigateToProfile(context, user.uid);
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                    ),
                  )
                ],
              ),

            if (user == null)
              IconButton(
                onPressed: () {
                  ref
                      .read(authControllerProvider.notifier)
                      .signInWithGoogle(context);
                },
                icon: const Icon(Icons.login),
              ),
          ],
        ),
        body: Constants.tabWidgets[_page],
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: CupertinoTabBar(
            activeColor: currentTheme.iconTheme.color,
            backgroundColor: currentTheme.bottomAppBarColor,
            onTap: onPageChanged,
            currentIndex: _page,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Add Task Category',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Collaborate',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.call_outlined),
                label: 'Join Call',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.report),
                label: 'Report',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
