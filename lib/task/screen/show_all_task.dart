import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_mate/auth/controller/auth_controller.dart';
import 'package:task_mate/theme/pallete.dart';

import '../../auth/repository/auth_repository.dart';
import '../controller/task_controller.dart';
import 'show_tasks.dart';

class ShowAllTask extends ConsumerStatefulWidget {
  const ShowAllTask({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShowAllTaskState();
}

class _ShowAllTaskState extends ConsumerState<ShowAllTask> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    final currentTheme = ref.watch(themeNotifierProvider);

    final usersTask = ref.watch(userTaskProvider);

    final usersData = usersTask.when(
      data: (data) => data,
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (e, s) => const Center(
        child: Text('Error'),
      ),
    );

    Future<void> _refreshUserData() async {
      final authRepository = ref.read(authRepositoryProvider);

      try {
        await authRepository.refreshUserData((user) {
          ref.read(userProvider.notifier).update((state) => user);
        });
      } catch (e) {
        // Handle error, e.g., show an error message
        print('Error refreshing user data: $e');
      }
    }

    final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();

    return MaterialApp(
      theme: currentTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            user == null
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : usersData is List && usersData.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'No task found, Start adding task so that you don\'t forget your important task',
                            style: TextStyle(
                              color: currentTheme.brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      )
                    // : RefreshIndicator(
                    //     key: _refreshIndicatorKey,
                    //     onRefresh: _refreshUserData,
                    //     child: usersTask.when(
                    //       data: (data) => SingleChildScrollView(
                    //         physics: const AlwaysScrollableScrollPhysics(),
                    //         child: GridView.count(
                    //           shrinkWrap: true,
                    //           physics: const NeverScrollableScrollPhysics(),
                    //           crossAxisCount: 2,
                    //           children: [
                    //             ...data.map(
                    //               (task) => LongPressDraggable(
                    //                 data: task,
                    //                 feedback: Opacity(
                    //                   opacity: 0.8,
                    //                   child: ShowTasks(tasks: task),
                    //                 ),
                    //                 child: ShowTasks(tasks: task),
                    //               ),
                    //             ),
                    //             // AddCard(),
                    //           ],
                    //         ),
                    //       ),
                    //       loading: () => const Center(
                    //         child: CircularProgressIndicator.adaptive(),
                    //       ),
                    //       error: (error, stack) => Center(
                    //         child: Text(error.toString()),
                    //       ),
                    //     ),
                    //   ),

                    : ref.watch(userTaskProvider).when(
                          data: (data) => Expanded(
                            child: SingleChildScrollView(
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                children: [
                                  ...data.map(
                                    (task) => LongPressDraggable(
                                      data: task,
                                      feedback: Opacity(
                                        opacity: 0.8,
                                        child: ShowTasks(tasks: task),
                                      ),
                                      child: ShowTasks(tasks: task),
                                    ),
                                  ),
                                  // AddCard(),
                                ],
                              ),
                            ),
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                          error: (error, stack) => Center(
                            child: Text(error.toString()),
                          ),
                        ),
          ],
        ),
      ),
    );
  }
}
