import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_mate/collaboration/controller/session_controller.dart';

import '../model/session_model.dart';

class TaskCollaboration extends ConsumerStatefulWidget {
  const TaskCollaboration({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TaskCollaborationState();
}

class _TaskCollaborationState extends ConsumerState<TaskCollaboration> {
  @override
  Widget build(BuildContext context) {
    final sessionController = ref.watch(sessionControllerProvider.notifier);

    final TextEditingController titleController = TextEditingController();

    final TextEditingController descriptionController = TextEditingController();

    final TextEditingController dateController = TextEditingController();

    final TextEditingController timeController = TextEditingController();

    final TextEditingController statusController = TextEditingController();

    @override
    void dispose() {
      titleController.dispose();
      descriptionController.dispose();
      dateController.dispose();
      timeController.dispose();
      statusController.dispose();
      super.dispose();
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Create a new session
                  String sessionId = await sessionController.createNewSession();
                  // Optionally, you can navigate to a new screen or show a dialog
                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('New Session Created'),
                        content: Text('Session ID: $sessionId'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Create New Session'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: statusController,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // add task to session
                  await sessionController.addTaskToSession(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    date: dateController.text.trim(),
                    time: timeController.text.trim(),
                    status: statusController.text.trim(),
                  );
                },
                child: const Text('Add Task to Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
