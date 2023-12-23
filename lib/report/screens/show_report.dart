import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../../model/task_model.dart';
import '../../task/controller/task_controller.dart';

class ShowReport extends ConsumerStatefulWidget {
  const ShowReport({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShowReportState();
}

class _ShowReportState extends ConsumerState<ShowReport> {
  var completedTaskLength = 0;

  var inCompleteTaskLength = 0;

  var totalTodos = 0;

  bool congratsDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void _showCongratsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have completed all tasks. Well done!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((value) async {
    });
  }

  @override
  Widget build(BuildContext context) {
    final userTasks = ref.watch(userTaskProvider);

    bool congratsMessageShown = false;

    int countIncompleteTodos(List<Tasks> tasks) {
      int count = 0;

      for (var task in tasks) {
        for (var todo in task.todos) {
          if (!todo.isDone) {
            count++;
          }
        }
      }

      return count;
    }

    int totalCountOfTodos(List<Tasks> tasks) {
      int count = 0;

      for (var task in tasks) {
        count += task.todos.length;
      }

      totalTodos = count;

      return count;
    }

    userTasks.when(
      data: (value) {
        // Count total todos
        totalTodos = totalCountOfTodos(value);

        inCompleteTaskLength = countIncompleteTodos(value);

        // Reset the completed task count before counting
        completedTaskLength = 0;

        // Count completed tasks
        for (var task in value) {
          for (var todo in task.todos) {
            if (todo.isDone) {
              completedTaskLength++;
            }
          }
        }
        // Show congratulatory message if all tasks are completed
        if (totalTodos > 0 &&
            totalTodos == completedTaskLength &&
            !congratsMessageShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCongratsDialog(context);
            congratsMessageShown = true;
          });
        }
      },
      loading: () {
        const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
      error: (e, s) {
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      },
    );

    double completionPercentage =
        totalTodos == 0 ? 0 : completedTaskLength / totalTodos * 100;

    Color selectedColor;

    if (completionPercentage >= 99) {
      selectedColor = Colors.redAccent;
    } else if (completionPercentage >= 100) {
      selectedColor = Colors.greenAccent;
    } else {
      selectedColor = Colors.blueAccent;
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
              child: Text(
                DateFormat.yMMMMd().format(
                  DateTime.now(),
                ),
                style: TextStyle(
                  fontSize: 14.0.textPercentage,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.0.widthPercent),
              child: const Divider(thickness: 2),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 3.0.widthPercent, horizontal: 4.0.widthPercent),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatus(
                      Colors.blueAccent, inCompleteTaskLength, 'Live Tasks'),
                  _buildStatus(Colors.greenAccent, completedTaskLength,
                      'Task Completed'),
                  _buildStatus(Colors.redAccent, totalTodos, 'Created'),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            UnconstrainedBox(
              child: SizedBox(
                height: 70.0.widthPercent,
                width: 70.0.widthPercent,
                child: CircularStepProgressIndicator(
                  totalSteps: totalTodos == 0 ? 1 : totalTodos,
                  currentStep: completedTaskLength,
                  stepSize: 20,
                  selectedColor: selectedColor,
                  padding: 0,
                  width: 150,
                  height: 150,
                  selectedStepSize: 22,
                  roundedCap: (_, __) => true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          '${completionPercentage.toStringAsFixed(0)}% Completed',
                          style: TextStyle(
                            fontSize: 12.0.textPercentage,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(),
                      Text(
                        '$completedTaskLength of $totalTodos Tasks',
                        style: TextStyle(
                          fontSize: 12.0.textPercentage,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12.0.textPercentage,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildStatus(Color color, int number, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 3.0.widthPercent,
          width: 3.0.widthPercent,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 0.5.widthPercent,
            ),
          ),
        ),
        const SizedBox(width: 3.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$number',
              style: TextStyle(
                fontSize: 12.0.textPercentage,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.0.textPercentage,
                color: Colors.grey,
              ),
              softWrap: true,
            ),
          ],
        )
      ],
    );
  }
}
