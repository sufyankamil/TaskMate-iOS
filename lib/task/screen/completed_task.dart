import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_mate/core/utils/extensions.dart';


import '../../../model/task_model.dart';
import '../../../model/todo.dart';
import '../../theme/pallete.dart';
import '../controller/task_controller.dart';

class CompletedTask extends ConsumerStatefulWidget {
  final String taskId;

  const CompletedTask({super.key, required this.taskId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CompletedTaskState();
}

class _CompletedTaskState extends ConsumerState<CompletedTask> {
  @override
  Widget build(BuildContext context) {
    return doneTask();
  }

  Widget doneTask() {
    final currentTheme = ref.watch(themeNotifierProvider.notifier);

    final isDark = currentTheme.isDark;

    List<String> todoTitles = [];

    var todoIsDoneStatus = <bool>[];

    final task = ref.watch(taskByIdProvider(widget.taskId));

    var isDoneLength = 0;

    // Check if the task is available
    if (task is AsyncData<Tasks>) {
      // Access the value inside AsyncData
      Tasks tasks = task.value;

      // Filter completed todos
      List<Todo> completedTodos =
          tasks.todos.where((todo) => todo.isDone).toList();

      // Get the titles of completed todos
      todoTitles = completedTodos.map((todo) => todo.title).toList();

      // Get the todos isDone status
      todoIsDoneStatus = completedTodos.map((todo) => true).toList();

      // Get the length of completed todos
      isDoneLength = completedTodos.length;
    }

    if (todoTitles.isNotEmpty) {
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
              'Task Completed $isDoneLength',
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
          for (int index = 0; index < todoTitles.length; index++)
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
                      activeColor: Colors.green,
                      value: todoIsDoneStatus[index],
                      onChanged: (value) {},
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
                    child: Text(
                      todoTitles[index],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0.textPercentage,
                        decoration: TextDecoration.lineThrough,
                        color: isDark ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10.0),
        ],
      );
    } else {
      return Container();
    }
  }
}
