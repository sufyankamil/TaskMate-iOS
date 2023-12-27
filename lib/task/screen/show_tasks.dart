import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../../model/task_model.dart';
import '../../theme/pallete.dart';

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

    return MaterialApp(
      theme: currentTheme,
      debugShowCheckedModeBanner: false,
      home: GestureDetector(
        onTap: () {
          navigateToTaskDetail(context, tasks.id);
        },
        child: Container(
          width: squreWidth / 2,
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
                Theme.of(context).platform == TargetPlatform.android
                    ? Padding(
                        padding: EdgeInsets.all(2.0.widthPercent),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              IconData(
                                Icons.nature_people.codePoint,
                                fontFamily: Icons.nature_people.fontFamily,
                                fontPackage: Icons.nature_people.fontPackage,
                              ),
                              color: color,
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: isDarkTheme
                                    ? currentTheme.primaryColorLight
                                    : currentTheme.primaryColorDark,
                              ),
                              onSelected: (value) {
                                if (value == 'open') {
                                  // Handle delete task
                                } else if (value == 'edit') {
                                  // Handle edit task
                                } else if (value == 'delete') {
                                  // Handle open task
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'open',
                                  child: Text('Open Task'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit Task'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete Task'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 7),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
                        child: Text(
                          tasks.title,
                          style: TextStyle(
                            fontSize: 16.4,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme
                                ? Colors.white
                                : currentTheme.primaryColorDark,
                            decoration: TextDecoration.none,
                          ),
                          softWrap: true,
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
