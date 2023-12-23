import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:task_mate/core/utils/extensions.dart';
import 'package:task_mate/task/screen/completed_task.dart';

import '../../../model/task_model.dart';
import '../../../model/todo.dart';
import '../../../theme/pallete.dart';
import '../controller/task_controller.dart';

class OnGoingTask extends ConsumerStatefulWidget {
  final String taskId;

  const OnGoingTask({super.key, required this.taskId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnGoingTaskState();
}

class _OnGoingTaskState extends ConsumerState<OnGoingTask> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);

    bool isDarkTheme = themeNotifier.isDark;

    return _buildTaskList(ref);
  }

  Widget _buildTaskList(WidgetRef ref) {
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);

    bool isDarkTheme = themeNotifier.isDark;
    int todosLength = 0;

    List<String> todoTitles = [];

    var todoIsDoneStatus = <bool>[];

    final taskController = ref.watch(taskControllerProvider.notifier);

    final task = ref.watch(taskByIdProvider(widget.taskId));

    // Check if the task is available
    if (task is AsyncData<Tasks>) {
      // Access the value inside AsyncData
      Tasks tasks = task.value;

      // Get the length of the todos list
      todosLength = tasks.todos.length;

      // Get the titles of todos
      todoTitles = tasks.todos.map((todo) => todo.title).toList();

      // Get the todos isDone sttaus
      todoIsDoneStatus = tasks.todos.map((todo) => todo.isDone).toList();
    }

    List<String> tasks = [];

    final usersTask = ref.watch(userTaskProvider);

    final usersData = usersTask.when(
      data: (data) => data,
      loading: () =>
          null, // Return null for loading state or handle it as needed
      error: (e, s) =>
          null, // Return null for error state or handle it as needed
    );

    if (usersData != null) {
      // Fetch the dates when task was created
      for (var task in usersData) {
        tasks.add(DateFormat('dd-MM-yyyy').format(task.createdAt));
      }

      // Sort the dates in descending order
      tasks.sort((a, b) => b.compareTo(a));

      // Store the latest date
      String latestDate = tasks.first;

      // Get the index of the latest date
      int latestDateIndex = tasks.indexOf(latestDate);

      // Get the latest task
      Tasks latestTask = usersData[latestDateIndex];
    } else {
      // Handle loading or error state here if necessary
      if (kDebugMode) {
        print('Loading or Error State');
      }
    }

    if (todoTitles.isNotEmpty) {
      const SizedBox(height: 10.0);
      return ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 9.0.widthPercent,
              vertical: 3.0.widthPercent,
            ),
            child: Text(
              'In Progress ($todosLength)',
              style: TextStyle(
                fontSize: 16.0.textPercentage,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0.widthPercent),
            child: const Divider(thickness: 2),
          ),
          const SizedBox(height: 10.0),
          for (String title in todoTitles)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 9.0.widthPercent,
                vertical: 3.0.widthPercent,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox.adaptive(
                      value: todoIsDoneStatus[todoTitles.indexOf(title)],
                      onChanged: (value) {
                        if (kDebugMode) {
                          print("value: $value");
                        }
                        Tasks? tasks = task.value;

                        Todo todo = tasks!.todos[todoTitles.indexOf(title)];

                        if (kDebugMode) {
                          print("Before update - isDone: ${todo.isDone}");
                        }

                        taskController.updateTodoIsDone(tasks, todo, value!);

                        if (kDebugMode) {
                          print("After update - isDone: ${todo.isDone}");
                        }

                        if (value) {
                          try {
                            taskController.updateKarma(tasks);
                          } catch (e) {
                            Fluttertoast.showToast(msg: e.toString());
                          }
                        }

                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12.0.textPercentage,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10.0),
          CompletedTask(taskId: widget.taskId),
        ],
      );
    } else {
      const SizedBox(height: 20.0);
      return Column(
        children: [
          const SizedBox(height: 20.0),
          Lottie.asset(
            'assets/images/task_animation.json',
            height: 65.0.textPercentage,
          ),
          Text(
            'Start adding task by clicking + ' 'button below',
            style: TextStyle(
              fontSize: 13.0.textPercentage,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  }
}
