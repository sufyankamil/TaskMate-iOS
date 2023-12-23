import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../../../model/task_model.dart';
import '../controller/task_controller.dart';

class SubTask extends ConsumerStatefulWidget {
  final String taskId;

  const SubTask({super.key, required this.taskId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SubTaskState();
}

class _SubTaskState extends ConsumerState<SubTask> {
  String title = '';

  final TextEditingController titleController = TextEditingController();

  final GlobalKey<FormState> formKeys = GlobalKey<FormState>();

  final taskController = postControllerProvider.notifier;

  @override
  Widget build(BuildContext context) {
    final taskDetails = ref.watch(taskByIdProvider(widget.taskId));

    // Check the status of the AsyncData
    if (taskDetails is AsyncData<Tasks>) {
      // Access the value inside AsyncData
      Tasks tasks = taskDetails.value;

      // Access specific properties of the Tasks object
      String taskId = tasks.id;
      title = tasks.title;

      // If 'createdAt' is a DateTime object, format it for display
      String formattedCreatedAt = tasks.createdAt.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task to $title'),
      ),
      body: Form(
        key: formKeys,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 2.0.widthPercent, horizontal: 5.0.widthPercent),
              child: TextFormField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (formKeys.currentState!.validate()) {
                        formKeys.currentState!.save();

                        // Fetch the Tasks object using taskByIdProvider
                        final taskDetails =
                            ref.watch(taskByIdProvider(widget.taskId));
                        // Check the status of the AsyncData
                        if (taskDetails is AsyncData<Tasks>) {
                          // Access the value inside AsyncData
                          Tasks tasks = taskDetails.value;

                          // Call the updateTasksWithSubTask function
                          ref
                              .read(postControllerProvider.notifier)
                              .updateTasksWithSubTask(
                                tasks,
                                titleController.text,
                              );
                        }
                      }
                      titleController.clear();
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                  ),
                  hintText: 'Task Title',
                  hintStyle: TextStyle(
                    fontSize: 12.0.textPercentage,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.0.widthPercent,
                    vertical: 2.0.widthPercent,
                  ),
                ),
                style: TextStyle(
                  fontSize: 12.0.textPercentage,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter task title';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
