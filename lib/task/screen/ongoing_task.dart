import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:routemaster/routemaster.dart';
import 'package:task_mate/common/constants.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../../../model/task_model.dart';
import '../../../model/todo.dart';
import '../controller/task_controller.dart';

class OnGoingTask extends ConsumerStatefulWidget {
  final String taskId;

  final List<String> subTaskIds;

  final int selectedChoiceIndex;

  const OnGoingTask({
    super.key,
    required this.taskId,
    required this.selectedChoiceIndex,
    required this.subTaskIds,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnGoingTaskState();
}

class _OnGoingTaskState extends ConsumerState<OnGoingTask> {
  void navigateToSubTaskDetail(BuildContext context, String taskId,
      List<String> subTaskIds, int selectedSubChoiceIndex) {
    final subTaskIdsQueryParam = subTaskIds.join(',');
    Routemaster.of(context).push(
        '/sub-task-detail/$taskId?subTaskIds=$subTaskIdsQueryParam&selectedSubChoiceIndex=$selectedSubChoiceIndex');
  }

  int selectedIndex = 0;

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
    List<String> todoTitles = [];

    List<String> todosDescription = [];

    final taskController = ref.watch(taskControllerProvider.notifier);

    final task = ref.read(taskByIdProvider(widget.taskId));

    // Check if the task is available
    if (task is AsyncData<Tasks>) {
      // Access the value inside AsyncData
      Tasks tasks = task.value;

      // Get the length of the todos list

      // Get the titles of todos
      todoTitles = tasks.todos.map((todo) => todo.title).toList();

      todosDescription = tasks.todos.map((todo) => todo.description).toList();

      // Get the todos isDone sttaus
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
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            divider(),
            slidableWidget(
                todoTitles, todosDescription, task, taskController, doNothing),
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
      List<String> todosDescription,
      AsyncValue<Tasks> task,
      TaskController taskController,
      // int selectedChoiceIndex,
      void Function(BuildContext context) doNothing) {
    return Expanded(
      child: ListView.builder(
        itemCount: todoTitles.length,
        itemBuilder: (context, index) {
          Tasks? tasks = task.value;
          List<Todo> todos = tasks?.todos ?? [];
          Todo todo = todos[index];
          return Builder(builder: (BuildContext builderContext) {
            if (widget.selectedChoiceIndex == 0 && todo.isPending == true) {
              return listOfSubTask(todoTitles, todosDescription, index, todos,
                  taskController, tasks);
            } else if (widget.selectedChoiceIndex == 1 &&
                todo.inProgress == true) {
              return listOfSubTask(todoTitles, todosDescription, index, todos,
                  taskController, tasks);
            } else if (widget.selectedChoiceIndex == 2 && todo.isDone == true) {
              return listOfSubTask(todoTitles, todosDescription, index, todos,
                  taskController, tasks);
            } else {
              return const SizedBox();
            }
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
      List<String> todosDescription,
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
          /////
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
      child: listOfSubTask(
          todoTitles, todosDescription, index, todos, taskController, tasks),
    );
  }

  showCupertinoModal(
    BuildContext context,
    List<Todo> todos,
    List<String> todoTitles,
    List<String> todosDescription,
    TaskController taskController,
    Tasks? tasks,
    int index,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Move Card?'),
          content: const Text(
              'If you move this card, you can see this card is in progress!'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                int selectedChoiceIndex = widget.selectedChoiceIndex;

                if (todos.isNotEmpty) {
                  Todo todo = todos[todoTitles.indexOf(todoTitles[index])];

                  // Perform action based on the selected choice
                  switch (selectedChoiceIndex) {
                    case 0:
                      // Update todo as pending
                      taskController.updateTodoInProgress(tasks!, todo, true);
                      Navigator.of(context);
                      break;
                    case 1:
                      // Update todo as in progress
                      taskController.updateTodoIsDone(tasks!, todo, true);
                      Navigator.of(context);
                      break;

                    default:
                      break;
                  }

                  try {
                    taskController.updateKarma(tasks!);
                  } catch (e) {
                    Fluttertoast.showToast(msg: e.toString());
                  }

                  Fluttertoast.showToast(msg: Constants.updateTask);
                  setState(() {});
                }
              },
              child: const Text('Move Card'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  GestureDetector listOfSubTask(
    List<String> todoTitles,
    List<String> todosDescription,
    int index,
    List<Todo> todos,
    TaskController taskController,
    Tasks? tasks,
  ) {
    Todo todo = todos[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        navigateToSubTaskDetail(
          context,
          widget.taskId,
          widget.subTaskIds,
          selectedIndex,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 35.0.widthPercent,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF252E41)),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              top: 8.0,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(todoTitles[index]),
                        subtitle: Text(todosDescription[index], maxLines: 1),
                        titleTextStyle: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        subtitleTextStyle: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_file,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '4',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.chat,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '2',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                              ),
                            ),
                            SizedBox(width: 40.0.widthPercent),
                            ElevatedButton(
                              onPressed: todo.isDone
                                  ? null
                                  : () {
                                      showCupertinoModal(
                                        context,
                                        todos,
                                        todoTitles,
                                        todosDescription,
                                        taskController,
                                        tasks,
                                        index,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                todo.isDone ? "Complete" : "Move",
                                style: TextStyle(
                                  fontSize: 10.0.textPercentage,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
