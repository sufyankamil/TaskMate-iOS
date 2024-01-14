import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_mate/auth/controller/auth_controller.dart';
import 'package:task_mate/theme/pallete.dart';

import '../../model/task_model.dart';
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
      data: (data) {
        final filteredTasks =
            data.where((task) => task.isCollaborative == false).toList();

        if (filteredTasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Text(
                'No task found, Start adding tasks so that you don\'t forget your important tasks',
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
          );
        } else {
          return Expanded(
            child: SingleChildScrollView(
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                children: [
                  ...filteredTasks.map(
                    (task) => LongPressDraggable(
                      data: task,
                      feedback: Opacity(
                        opacity: 0.8,
                        child: ShowTasks(tasks: task),
                      ),
                      child: ShowTasks(tasks: task),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (e, s) => Center(
        child: Text('Error: $e'),
      ),
    );

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
                : usersData,
          ],
        ),
      ),
    );
  }
}
