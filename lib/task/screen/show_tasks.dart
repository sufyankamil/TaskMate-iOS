import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:task_mate/common/constants.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../../model/task_model.dart';
import '../../theme/pallete.dart';
import '../controller/task_controller.dart';

class ShowTasks extends ConsumerWidget {
  final Tasks tasks;

  const ShowTasks({super.key, required this.tasks});

  void navigateToTaskDetail(BuildContext context, String taskId) {
    Routemaster.of(context).push('/task-detail/$taskId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final squreWidth = MediaQuery.of(context).size.width - 12.0.widthPercent;

    final currentTheme = ref.watch(themeNotifierProvider);

    String? hexColorString = tasks.color;

    Color color = hexStringToColor(hexColorString!);

    final themeNotifier = ref.watch(themeNotifierProvider.notifier);

    bool isDarkTheme = themeNotifier.isDark;

    final taskController = ref.watch(taskControllerProvider.notifier);

    bool isTodosEmpty() {
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

    confrimCollaborate(
      TaskController taskController,
    ) {
      showPlatformDialog(
        context: context,
        builder: (_) => BasicDialogAlert(
          title: Text(
            Constants.addToCollaboration,
            style: TextStyle(
              color: isDarkTheme
                  ? currentTheme.primaryColorLight
                  : currentTheme.primaryColorDark,
            ),
          ),
          content: Text(
            Constants.collaborationConfirmation,
            style: TextStyle(
              color: isDarkTheme
                  ? currentTheme.primaryColorLight
                  : currentTheme.primaryColorDark,
            ),
          ),
          actions: <Widget>[
            BasicDialogAction(
              title: Text(
                Constants.cancel,
                style: TextStyle(
                  color: isDarkTheme
                      ? currentTheme.primaryColorLight
                      : currentTheme.primaryColorDark,
                ),
              ),
              onPressed: () {
                Routemaster.of(context).pop();
              },
            ),
            BasicDialogAction(
              title: Text(
                Constants.confirm,
                style: TextStyle(
                  color: isDarkTheme
                      ? currentTheme.primaryColorLight
                      : currentTheme.primaryColorDark,
                ),
              ),
              onPressed: () {
                Routemaster.of(context).pop();
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
            ),
          ],
        ),
      );
    }

    return MaterialApp(
      theme: currentTheme,
      debugShowCheckedModeBanner: false,
      home: GestureDetector(
        onTap: () {
          navigateToTaskDetail(context, tasks.id);
        },
        child: Container(
          width: squreWidth,
          height: squreWidth / 2,
          margin: EdgeInsets.all(4.0.widthPercent),
          decoration: BoxDecoration(
            color: isDarkTheme ? currentTheme.primaryColorDark : Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: isDarkTheme ? Colors.grey[900]! : Colors.grey[300]!,
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StepProgressIndicator(
                  totalSteps: isTodosEmpty() ? 1 : tasks.todos.length,
                  currentStep: isTodosEmpty() ? 0 : getDoneTodo(tasks),
                  padding: 0,
                  size: 5,
                  selectedGradientColor: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      color.withOpacity(0.5),
                      color,
                    ],
                  ),
                  unselectedGradientColor: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      currentTheme.secondaryHeaderColor,
                      currentTheme.primaryColorLight.withOpacity(0.5),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 7),

                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
                        child: Row(
                          children: [
                            Text(
                              tasks.title,
                              style: TextStyle(
                                fontSize: 12.4,
                                fontWeight: FontWeight.bold,
                                color: isDarkTheme
                                    ? Colors.white
                                    : currentTheme.primaryColorDark,
                                decoration: TextDecoration.none,
                              ),
                              softWrap: true,
                            ),
                            const Spacer(),
                            PopupMenuButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: isDarkTheme
                                    ? currentTheme.primaryColorLight
                                    : currentTheme.primaryColorDark,
                              ),
                              onSelected: (value) {
                                if (value == 'add-to-collaborate') {}
                              },
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem<String>(
                                  value: 'add-to-collaborate',
                                  child: TextButton(
                                    onPressed: () {
                                      confrimCollaborate(taskController);
                                    },
                                    child: const Text(
                                        Constants.addToCollaboration),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
                        child: Text(
                          '${tasks.todos.length} Tasks',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.normal,
                            color: isDarkTheme
                                ? currentTheme.primaryColorLight
                                : currentTheme.primaryColorDark,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
                        child: Text(
                          'Created on: ${DateFormat('dd-MM-yyyy').format(tasks.createdAt.toLocal())}',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.normal,
                            color: isDarkTheme
                                ? currentTheme.primaryColorLight
                                : currentTheme.primaryColorDark,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),
                      // show time
                      tasks.createdAt.toLocal().isAfter(
                              DateTime.now().subtract(const Duration(days: 1)))
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.0.widthPercent),
                              child: Text(
                                'Time: ${DateFormat('HH:mm:ss').format(tasks.createdAt.toLocal())}',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal,
                                  color: isDarkTheme
                                      ? currentTheme.primaryColorLight
                                      : currentTheme.primaryColorDark,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.0.widthPercent),
                              child: Text(
                                'Time: ${DateFormat('HH:mm').format(tasks.createdAt.toLocal())}',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal,
                                  color: isDarkTheme
                                      ? currentTheme.primaryColorLight
                                      : currentTheme.primaryColorDark,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
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
