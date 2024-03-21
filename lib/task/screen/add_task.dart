import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
                  // await showAddTaskDialog(context);
                  addTask(context, ref);
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

  void addTask(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    TextEditingController titleController = TextEditingController();

    TextEditingController descriptionController = TextEditingController();

    TextEditingController subTitleController = TextEditingController();

    String? errorText1 = "Please enter a task title";

    String? errorText2 = "Please enter a task Description";

    String? formattedDate = '';

    DateTime selectedDate = DateTime.now();

    TimeOfDay selectedTime = TimeOfDay.now();

    Future<void> selectDate(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null && pickedDate != selectedDate) {
        setState(() {
          selectedDate = pickedDate;
          formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
        });
      }
    }

    // Convert TimeOfDay to DateTime for formatting
    DateTime dateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      selectedTime.hour,
      selectedTime.minute,
    );

    Future<void> selectTime(BuildContext context) async {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );

      if (pickedTime != null && pickedTime != selectedTime) {
        setState(() {
          selectedTime = pickedTime;
          DateFormat('h:mm a').format(dateTime);
        });
      }
    }

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return CupertinoPopupSurface(
          child: Form(
            key: _formKey,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: 200.0.widthPercent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Routemaster.of(context).pop();
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Add Project',
                    style: TextStyle(
                      fontFamily: 'MyFont',
                      fontSize: 7.0.widthPercent,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  titleWidget(titleController, errorText1),
                  const SizedBox(height: 20),
                  subTitleWidget(subTitleController, errorText2),
                  const SizedBox(height: 20),
                  CupertinoTextFormFieldRow(
                    maxLength: 300,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white),
                    prefix: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.description, color: Colors.white),
                    ),
                    controller: descriptionController,
                    placeholder: 'Task Description',
                    keyboardType: TextInputType.multiline,
                    padding: const EdgeInsets.all(12.0),
                    placeholderStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task description';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      descriptionController.text = value;
                      setState(() {
                        errorText2 = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextFormFieldRow(
                          style: const TextStyle(color: Colors.white),
                          prefix: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                                onTap: () => selectDate(context),
                                child: const Icon(Icons.date_range,
                                    color: Colors.white)),
                          ),
                          controller: TextEditingController(
                            text: "$formattedDate",
                          ),
                          placeholder: 'Select due date',
                          padding: const EdgeInsets.all(12.0),
                          placeholderStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a valid date';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              errorText2 = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  timerWidget(selectTime, context, selectedTime, errorText2),
                  const SizedBox(height: 20),
                  submitButton(
                    _formKey,
                    ref,
                    titleController,
                    descriptionController,
                    subTitleController,
                    formattedDate,
                    selectedTime,
                    context,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  CupertinoTextFormFieldRow titleWidget(
      TextEditingController titleController, String? errorText1) {
    return CupertinoTextFormFieldRow(
      style: const TextStyle(color: Colors.white),
      prefix: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.title, color: Colors.white),
      ),
      controller: titleController,
      placeholder: 'Task Title',
      padding: const EdgeInsets.all(12.0),
      placeholderStyle: const TextStyle(
        color: Colors.grey,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a task title';
        }
        return null;
      },
      onChanged: (value) {
        titleController.text = value;
        setState(() {
          errorText1 = null;
        });
      },
    );
  }

  CupertinoTextFormFieldRow subTitleWidget(
      TextEditingController subTitleController, String? errorText1) {
    return CupertinoTextFormFieldRow(
      style: const TextStyle(color: Colors.white),
      prefix: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.subtitles, color: Colors.white),
      ),
      controller: subTitleController,
      placeholder: 'Sub Task Title / Project Group',
      padding: const EdgeInsets.all(12.0),
      placeholderStyle: const TextStyle(
        color: Colors.grey,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a sub-task title';
        }
        return null;
      },
      onChanged: (value) {
        subTitleController.text = value;
        setState(() {
          errorText1 = null;
        });
      },
    );
  }

  Row timerWidget(Future<void> Function(BuildContext context) selectTime,
      BuildContext context, TimeOfDay selectedTime, String? errorText2) {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextFormFieldRow(
            prefix: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                    onTap: () => selectTime(context),
                    child: const Icon(Icons.timer, color: Colors.white))),
            style: const TextStyle(color: Colors.white),
            controller: TextEditingController(
              text: selectedTime.format(context),
            ),
            placeholder: 'Select time',
            padding: const EdgeInsets.all(12.0),
            placeholderStyle: const TextStyle(
              color: Colors.grey,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select time';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                errorText2 = null;
              });
            },
          ),
        ),
      ],
    );
  }

  CupertinoButton submitButton(
      GlobalKey<FormState> _formKey,
      WidgetRef ref,
      TextEditingController titleController,
      TextEditingController descriptionController,
      TextEditingController subtitleController,
      String? formattedDate,
      TimeOfDay selectedTime,
      BuildContext context) {
    return CupertinoButton.filled(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          ref.read(postControllerProvider.notifier).addTask(
                context: context,
                title: titleController.text.trim(),
                description: descriptionController.text.trim(),
                subTitle: subtitleController.text.trim(),
                date: formattedDate!,
                time: selectedTime.format(context),
              );

          titleController.clear();
          descriptionController.clear();

          Routemaster.of(context).pop();
        }
      },
      child: const Text('Submit'),
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
