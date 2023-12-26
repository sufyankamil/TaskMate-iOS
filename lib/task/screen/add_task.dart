import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../../core/values/colors.dart';
import '../controller/task_controller.dart';

class AddTask extends ConsumerStatefulWidget {
  const AddTask({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddTaskState();
}

class _AddTaskState extends ConsumerState<AddTask> {
  Future<List<String>> fetchTaskIds() async {
    List<String> taskIds = [];
    final taskController = ref.watch(postControllerProvider.notifier);
    final tasks = await taskController.fetchUserTasks().first;
    for (var task in tasks) {
      taskIds.add(task.id);
    }
    return taskIds;
  }

  Future<List<Widget>> getTabWidgets() async {
    List<Widget> tabWidgets = [];
    final taskIds = await fetchTaskIds();
    for (var taskId in taskIds) {
      tabWidgets.add(
        Tab(
          child: Text(
            taskId,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return tabWidgets;
  }

  void navigateToSubTask(BuildContext context, String title) {
    Routemaster.of(context).push('/sub-task/$title');
  }

  @override
  Widget build(BuildContext context) {
    double centerWidth =
        (MediaQueryData.fromView(WidgetsBinding.instance.window).size.width -
                12.0.widthPercent) /
            2;

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

    // Check if usersData is empty
    final bool isUserDataEmpty = usersData is Iterable && usersData.isNotEmpty;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0.widthPercent),
            child: Container(
              width: centerWidth,
              height: centerWidth,
              margin: const EdgeInsets.all(4.0),
              child: InkWell(
                onTap: () async {
                  await showAddTaskDialog(context);
                },
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(10.0),
                  color: Colors.grey,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.grey,
                          size: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Click on the + icon above to add a new task category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showAddTaskSheet(BuildContext context) async {
    showCupertinoModalSheet(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Add Task Category'),
          message: const Text('Enter the task category name'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                // Your existing logic for confirming the task
              },
              child: const Text('Confirm'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  Future<void> showAddTaskDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Add Task Category'),
          content: AddTaskForm(),
          actions: [],
        );
      },
    );
  }
}

class AddTaskForm extends ConsumerStatefulWidget {
  const AddTaskForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends ConsumerState<AddTaskForm> {
  final TextEditingController titleController = TextEditingController();

  final GlobalKey<FormState> formKeys = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(postControllerProvider);

    return SingleChildScrollView(
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Form(
              key: formKeys,
              child: Column(
                children: [
                  buildTitleTextField(),

                  const SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.0.widthPercent),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () {
                        if (formKeys.currentState!.validate()) {
                          formKeys.currentState!.save();
                          ref.read(postControllerProvider.notifier).addTask(
                                context: context,
                                title: titleController.text.trim(),
                              );
                        }
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void showAddTaskSheet(BuildContext context) {
    showCupertinoModalSheet(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Add Task Category'),
          message: const Text('Enter the task category name'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Future.delayed(Duration.zero, () {
                  if (formKeys.currentState!.validate()) {
                    formKeys.currentState!.save();
                    ref.read(postControllerProvider.notifier).addTask(
                          context: context,
                          title: titleController.text.trim(),
                        );
                  }
                });
              },
              child: const Text('Confirm'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  void buildTextFieldSheet(BuildContext context) {
    showCupertinoModalSheet(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: const Text('Add Task Category'),
            message: const Text('Enter the task category name'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Future.delayed(Duration.zero, () {
                    if (formKeys.currentState!.validate()) {
                      formKeys.currentState!.save();
                      ref.read(postControllerProvider.notifier).addTask(
                            context: context,
                            title: titleController.text.trim(),
                          );
                    }
                  });
                },
                child: const Text('Confirm'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          );
        });
  }

  Widget buildTitleTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.0.widthPercent),
      child: TextFormField(
        controller: titleController,
        decoration: buildInputDecoration('Task Title'),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter task title';
          }
          return null;
        },
        onSaved: (value) {},
      ),
    );
  }

  InputDecoration buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}
