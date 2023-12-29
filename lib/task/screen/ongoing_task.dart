import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:routemaster/routemaster.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../../../model/task_model.dart';
import '../../../model/todo.dart';
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
    return SingleChildScrollView(child: _buildTaskList(ref));
  }

  Widget _buildTaskList(WidgetRef ref) {
    return ref.watch(taskByIdProvider(widget.taskId)).when(
          data: (task) {
            return Column(
              children: [
                _buildTaskHeader(ref, task),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          error: (error, stack) => Center(
            child: Text(error.toString()),
          ),
        );
  }

  Widget emptyTask() {
    const SizedBox(height: 20.0);
    return Column(
      children: [
        const SizedBox(height: 20.0),
        Theme.of(context).platform == TargetPlatform.android
            ? Column(
                children: [
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
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start adding task by clicking + ' 'button below',
                    style: TextStyle(
                      fontSize: 13.0.textPercentage,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildTaskHeader(WidgetRef ref, Tasks task) {
    int todosLength = 0;

    List<String> todoTitles = [];

    var todoIsDoneStatus = <bool>[];

    final taskController = ref.watch(taskControllerProvider.notifier);

    final task = ref.read(taskByIdProvider(widget.taskId));

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

    Key uniqueKey = const Key('unique_slidable_key_0');

    void navigateToCompletedTask(BuildContext context, String taskId) {
      Routemaster.of(context).push('/completed-task/$taskId');
    }

    void doNothing(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Premium Feature'),
            content: const Text(
                'Once you have the premium version, you can share it with your friends.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }

    void futurePremium(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Premium Feature'),
            content: const Text(
                'Once you have the premium version, you can share it with your friends.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }

    if (todoTitles.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                inProgressCount(todosLength),
                const Spacer(),
                todoIsDoneStatus
                        .every((element) => element == true && todosLength > 0)
                    ? completedTaskPage(navigateToCompletedTask, taskController)
                    : const SizedBox()
              ],
            ),
            divider(),
            slidableWidget(todoTitles, task, taskController, doNothing),
          ],
        ),
      );
    }
    return emptyTask();
  }

  Padding divider() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.0.widthPercent),
        child: const Divider(thickness: 2));
  }

  Padding inProgressCount(int todosLength) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 5.0.widthPercent,
        vertical: 3.0.widthPercent,
      ),
      child: Text(
        'In Progress ($todosLength)',
        style: TextStyle(
          fontSize: 16.0.textPercentage,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Padding completedTaskPage(
      void Function(BuildContext context, String taskId)
          navigateToCompletedTask,
      TaskController taskController) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0.widthPercent),
      child: ElevatedButton(
        onPressed: () {
          navigateToCompletedTask(context, widget.taskId);
          taskController.changeChipIndex(1);
          setState(() {});
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(
          'Completed Task',
          style: TextStyle(
            fontSize: 10.0.textPercentage,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
      ),
    );
  }

  Expanded slidableWidget(
      List<String> todoTitles,
      AsyncValue<Tasks> task,
      TaskController taskController,
      void Function(BuildContext context) doNothing) {
    return Expanded(
      child: ListView.builder(
        itemCount: todoTitles.length,
        itemBuilder: (context, index) {
          Tasks? tasks = task.value;
          List<Todo> todos = tasks?.todos ?? [];
          return Builder(builder: (BuildContext builderContext) {
            return mainSlider(
                index, taskController, todos, doNothing, todoTitles, tasks);
          });
        },
      ),
    );
  }

  Slidable mainSlider(
      int index,
      TaskController taskController,
      List<Todo> todos,
      void Function(BuildContext context) futurePremium,
      List<String> todoTitles,
      Tasks? tasks) {
    return Slidable(
      key: Key('unique_slidable_key_$index'),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              taskController.deleteSubtaskById(widget.taskId, todos[index].id);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: (context) {
              futurePremium(context);
            },
            backgroundColor: const Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            flex: 2,
            onPressed: (context) {
              if (todos.isNotEmpty) {
                Todo todo = todos[todoTitles.indexOf(todoTitles[index])];

                if (todo.isDone) {
                  // If the task is completed, unmark it
                  if (kDebugMode) {
                    print("Before update - isDone: ${todo.isDone}");
                  }
                  taskController.updateTodoIsDone(tasks!, todo, false);
                } else {
                  if (kDebugMode) {
                    print("After update - isDone: ${todo.isDone}");
                  }

                  // Mark the task as done
                  taskController.updateTodoIsDone(tasks!, todo, true);
                }

                try {
                  taskController.updateKarma(tasks);
                } catch (e) {
                  Fluttertoast.showToast(msg: e.toString());
                }

                Fluttertoast.showToast(msg: 'Task Updated Successfully');
                setState(() {});
              }
            },
            backgroundColor: todos[index].isDone
                ? const Color(0xFFFE4A49)
                : const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: todos[index].isDone ? Icons.undo : Icons.check,
            label: todos[index].isDone ? 'Undo' : 'Mark as Completed',
          ),
        ],
      ),
      child: listOfSubTask(todoTitles, index),
    );
  }

  Container listOfSubTask(List<String> todoTitles, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          top: 8.0,
        ),
        child: Row(
          children: [
            Text(
              '${todoTitles.indexOf(todoTitles[index]) + 1}.',
              style: TextStyle(
                fontSize: 12.0.textPercentage,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text(todoTitles[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
