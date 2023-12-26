import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:task_mate/core/utils/extensions.dart';
import 'package:task_mate/task/screen/ongoing_task.dart';

import '../../../model/task_model.dart';
import '../../../theme/pallete.dart';
import '../controller/task_controller.dart';

class DetailedPage extends ConsumerStatefulWidget {
  final String taskId;

  const DetailedPage({super.key, required this.taskId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DetailedPageState();
}

class _DetailedPageState extends ConsumerState<DetailedPage> {
  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);

    final GlobalKey<FormState> formKeys = GlobalKey<FormState>();

    List<String> tasks = [];

    int taskCompleted(Tasks task) {
      int doneTodo = 0;
      for (var todo in task.todos) {
        // Check `if the current element is a Todo object with an isDone property
        if (todo.isDone) {
          doneTodo++;
        }
      }
      return doneTodo;
    }

    Color stringToColor(String colorString) {
      final buffer = StringBuffer();
      buffer.write(colorString.replaceAll('#', ''));
      if (buffer.length == 6 || buffer.length == 8) {
        buffer.write('FF'); // Add alpha channel if it's missing
      }
      return Color(int.parse(buffer.toString(), radix: 16));
    }

    bool isTodosEmpty(Tasks tasks) {
      if (tasks.todos.isEmpty) {
        return true;
      } else {
        return false;
      }
    }

    int getDoneTodo(Tasks task) {
      int doneTodo = 0;
      for (var todo in task.todos) {
        if (todo.isDone) {
          doneTodo++;
        }
      }
      return doneTodo;
    }

    void navigateToSubTask(BuildContext context, String taskId) {
      Routemaster.of(context).push('/sub-task/$taskId');
    }

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

    final usersNewData = usersTask.when(
      data: (data) => data,
      loading: () =>
          null, // Return null for loading state or handle it as needed
      error: (e, s) =>
          null, // Return null for error state or handle it as needed
    );

    if (usersNewData != null) {
      // Fetch the dates when task was created
      for (var task in usersNewData) {
        tasks.add(DateFormat('dd-MM-yyyy').format(task.createdAt));
      }

      // print('tasks: $tasks');

      // Sort the dates in descending order
      tasks.sort((a, b) => b.compareTo(a));
    } else {
      // Handle loading or error state here if necessary
      if (kDebugMode) {
        print('Loading or Error State');
      }
    }

    // Check if usersData is empty
    final bool isUserDataEmpty = usersData is Iterable && usersData.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: [
          IconButton(
            onPressed: () {
              // final userDataList = usersData.toList();

              if (kDebugMode) {
                print("userDataList: ");
              }
            },
            icon: const Tooltip(
              waitDuration: Duration(seconds: 100),
              message: 'Swipe on the task to see list of options',
              child: Icon(Icons.help_outline),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            ref.watch(taskByIdProvider(widget.taskId)).when(
                  data: (data) => Form(
                    key: formKeys,
                    child: SizedBox(
                      height: 40.0.widthPercent,
                      // height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      child: ListView(
                        children: [
                          SizedBox(height: 6.0.widthPercent),
                          taskTitle(stringToColor, data),
                          const SizedBox(height: 16.0),
                          stepper(data, isTodosEmpty, getDoneTodo,
                              stringToColor, currentTheme),
                          const SizedBox(height: 10.0),
                          Center(
                            child: Text(
                              '${taskCompleted(data)}/${data.todos.length} Tasks Completed',
                              style: TextStyle(
                                overflow: TextOverflow.clip,
                                fontSize: 12.0.textPercentage,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(error.toString()),
                  ),
                ),
            const SizedBox(height: 10.0),
            OnGoingTask(taskId: widget.taskId),
          ],
        ),
      ),

      // body: ref.watch(taskByIdProvider(widget.taskId)).when(
      //       data: (data) => SingleChildScrollView(
      //         child: Column(
      //           children: [
      //             Form(
      //               key: formKeys,
      //               child: SizedBox(
      //                 height: MediaQuery.of(context).size.height,
      //                 width: double.infinity,
      //                 child: ListView(
      //                   children: [
      //                     SizedBox(height: 6.0.widthPercent),
      //                     taskTitle(stringToColor, data),
      //                     const SizedBox(height: 16.0),
      //                     stepper(data, isTodosEmpty, getDoneTodo,
      //                         stringToColor, currentTheme),
      //                     const SizedBox(height: 10.0),
      //                     Center(
      //                       child: Text(
      //                         '${taskCompleted(data)}/${data.todos.length} Tasks Completed',
      //                         style: TextStyle(
      //                           overflow: TextOverflow.clip,
      //                           fontSize: 12.0.textPercentage,
      //                           color: Colors.grey,
      //                         ),
      //                       ),
      //                     ),
      //                     OnGoingTask(taskId: widget.taskId),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       loading: () => const Center(
      //         child: CircularProgressIndicator.adaptive(),
      //       ),
      //       error: (error, stackTrace) => Center(
      //         child: Text(error.toString()),
      //       ),
      //     ),
      floatingActionButton: isUserDataEmpty
          ? FloatingActionButton(
              onPressed: () {
                final userDataList = usersData.toList();

                if (kDebugMode) {
                  print("userDataList: $userDataList");
                }

                if (userDataList.isNotEmpty) {
                  navigateToSubTask(context, widget.taskId);
                }
              },
              child: const Icon(Icons.add),
            )
          : const SizedBox(),
    );
  }

  Padding stepper(
      Tasks data,
      bool Function(Tasks tasks) isTodosEmpty,
      int Function(Tasks task) getDoneTodo,
      Color Function(String colorString) stringToColor,
      ThemeData currentTheme) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0.widthPercent,
        right: 16.0.widthPercent,
        top: 3.0.widthPercent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${data.todos.length} Tasks',
            style: TextStyle(
              fontSize: 12.0.textPercentage,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 6.0.widthPercent),
          Expanded(
            child: StepProgressIndicator(
              totalSteps: isTodosEmpty(data) ? 1 : data.todos.length,
              currentStep: isTodosEmpty(data) ? 0 : getDoneTodo(data),
              size: 5,
              padding: 0,
              selectedGradientColor: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  stringToColor(data.color!).withOpacity(0.5),
                  stringToColor(data.color!),
                ],
              ),
              unselectedGradientColor: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  currentTheme.primaryColorLight,
                  currentTheme.primaryColorLight.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding taskTitle(
      Color Function(String colorString) stringToColor, Tasks data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0.widthPercent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_remove_alt_1_sharp,
                    color: stringToColor(data.color!),
                  ),
                  SizedBox(width: 5.0.widthPercent),
                  Text(data.title,
                      style: TextStyle(
                        overflow: TextOverflow.clip,
                        fontSize: 10.0.textPercentage,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
