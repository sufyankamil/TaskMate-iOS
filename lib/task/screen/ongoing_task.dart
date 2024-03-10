import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:routemaster/routemaster.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:task_mate/common/constants.dart';
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
                    Constants.onGoingAnimation,
                    height: 65.0.textPercentage,
                  ),
                  Text(
                    Constants.startAddingTask,
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
                    Constants.startAddingTask,
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
            title: const Text(Constants.premiumFeature),
            content: const Text(Constants.premiumText),
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
      //   return Card(
      //     elevation: 4.0,
      //     margin: const EdgeInsets.all(8.0),
      //     child: Padding(
      //       padding: const EdgeInsets.all(16.0),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Row(
      //             children: [
      //               _inProgressIndicator(todosLength),
      //               const Spacer(),
      //               _completedTaskButton(navigateToCompletedTask, taskController),
      //             ],
      //           ),
      //           const SizedBox(height: 10),
      //           _taskList(todoTitles, task, taskController, doNothing),
      //         ],
      //       ),
      //     ),
      //   );
      // }
      // return emptyTask();

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

  Widget _inProgressIndicator(int todosLength) {
    return Row(
      children: [
        Icon(Icons.work_outline, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8.0),
        Text(
          'In Progress ($todosLength)',
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _completedTaskButton(
      Function(BuildContext, String) navigateToCompletedTask,
      TaskController taskController) {
    return OutlinedButton.icon(
      icon: Icon(Icons.check_circle_outline,
          color: Theme.of(context).primaryColor),
      label: Text(Constants.completedTask),
      onPressed: () {
        navigateToCompletedTask(context, widget.taskId);
        taskController.changeChipIndex(1);
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _taskList(
      List<String> todoTitles,
      AsyncValue<Tasks> task,
      TaskController taskController,
      void Function(BuildContext context) doNothing) {
    // Remove the Expanded widget here as its parent will handle the sizing.
    return ListView.separated(
      shrinkWrap: true, // Add shrinkWrap
      physics:
          NeverScrollableScrollPhysics(), // Add this to prevent the ListView from scrolling independently
      itemCount: todoTitles.length,
      separatorBuilder: (context, index) =>
          Divider(color: Theme.of(context).dividerColor),
      itemBuilder: (context, index) {
        return _taskListItem(
            index, todoTitles, task, taskController, doNothing);
      },
    );
  }

  Widget _taskListItem(
      int index,
      List<String> todoTitles,
      AsyncValue<Tasks> task,
      TaskController taskController,
      void Function(BuildContext context) doNothing) {
    Tasks? tasks = task.value;
    List<Todo> todos = tasks?.todos ?? [];
    return Slidable(
      key: Key('slidable_task_item_$index'),
      // ... rest of your slidable logic here ...
      child: ListTile(
        leading: Text(
          '${index + 1}.',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title: Text(todoTitles[index]),
        trailing: IconButton(
          icon: Icon(todos[index].isDone
              ? Icons.check_circle
              : Icons.radio_button_unchecked),
          onPressed: () {
            // toggle the todo isDone state here
          },
        ),
      ),
    );
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
          Constants.completedTask,
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
            label: Constants.delete,
          ),
          SlidableAction(
            onPressed: (context) {
              // futurePremium(context);
              if (tasks.isCollaborative) {
                taskController.updateTodoIsCollaborative(tasks, false);

                Fluttertoast.showToast(
                    msg: Constants.unshareTask,
                    timeInSecForIosWeb: 4,
                    backgroundColor: Colors.red,
                    textColor: Colors.white);
              } else {
                taskController.updateTodoIsCollaborative(tasks, true);

                Fluttertoast.showToast(
                    msg: Constants.shareTask,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Colors.green,
                    textColor: Colors.white);
              }
            },
            backgroundColor: const Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: tasks!.isCollaborative ? Icons.share : Icons.share_outlined,
            label: tasks.isCollaborative ? Constants.unshare : Constants.share,
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
                  taskController.updateTodoIsDone(tasks, todo, false);
                } else {
                  // Mark the task as done
                  taskController.updateTodoIsDone(tasks, todo, true);
                }

                try {
                  taskController.updateKarma(tasks);
                } catch (e) {
                  Fluttertoast.showToast(msg: e.toString());
                }

                Fluttertoast.showToast(msg: Constants.updateTask);
                setState(() {});
              }
            },
            backgroundColor: todos[index].isDone
                ? const Color(0xFFFE4A49)
                : const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: todos[index].isDone ? Icons.undo : Icons.check,
            label:
                todos[index].isDone ? Constants.undo : Constants.taskCompleted,
          ),
        ],
      ),
      child: listOfSubTask(todoTitles, index),
    );
  }

  Container listOfSubTask(List<String> todoTitles, int index) {
    final _key1 = GlobalKey();

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
              child: Showcase(
                key: _key1,
                description: Constants.editTask,
                overlayColor: Colors.blueGrey,
                child: ListTile(
                  title: Text(todoTitles[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
