import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_mate/auth/controller/auth_controller.dart';
import 'package:task_mate/theme/pallete.dart';

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
                                  onDragStarted: () {
                                    // ref
                                    // .read(taskControllerProvider.notifier)
                                    // .changeDeleting(true);
                                  },
                                  onDraggableCanceled: (_, __) {
                                    // ref
                                    //     .read(taskControllerProvider.notifier)
                                    //     .changeDeleting(false);
                                  },
                                  onDragEnd: (_) {
                                    // ref
                                    //     .read(taskControllerProvider.notifier)
                                    //     .changeDeleting(false);
                                  },
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
