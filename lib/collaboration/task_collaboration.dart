import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_mate/collaboration/controller/session_controller.dart';

final sessionsCreatedProvider =
    StateNotifierProvider<SessionCounter, int>((ref) {
  return SessionCounter();
});

class SessionCounter extends StateNotifier<int> {
  SessionCounter() : super(0);

  void increment() {
    state++;
  }
}

class TaskCollaboration extends ConsumerStatefulWidget {
  const TaskCollaboration({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TaskCollaborationState();
}

class _TaskCollaborationState extends ConsumerState<TaskCollaboration> {
  late int sessionsCreated;

  @override
  void initState() {
    super.initState();
    sessionsCreated = ref.read(sessionsCreatedProvider);
  }

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

    String sessionId = '';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Create a new session
                      dynamic activeSession =
                          await SessionManager().get("activeSession");

                      if (activeSession != null &&
                          activeSession is String &&
                          activeSession.isNotEmpty) {
                        if (context.mounted) {
                          showPlatformDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: const Text('Active Session'),
                                content: const Text(
                                    "You already have an active session. Please end the current session to create a new one."),
                                actions: [
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        sessionId =
                            await sessionController.createNewSession(context);
                        Future.delayed(const Duration(seconds: 1), () {
                          Fluttertoast.showToast(
                            msg:
                                'Share this session id and share it with your friends whome you like to collaborate with.',
                            backgroundColor: Colors.green,
                            timeInSecForIosWeb: 5,
                            gravity: ToastGravity.TOP,
                          );
                        });
                        Future.delayed(const Duration(seconds: 3), () {
                          if (context.mounted) {
                            showPlatformDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: const Text('Session Created'),
                                  content:
                                      Text("Your session ID is: $sessionId"),
                                  actions: [
                                    CupertinoDialogAction(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        });
                        if (sessionId.isNotEmpty) {
                          setState(() {
                            sessionsCreated++;
                          });
                        }
                      }
                    },
                    child: const Text('Start session'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      // End the current session
                      dynamic activeSession =
                          await SessionManager().get("activeSession");

                      if (activeSession != null &&
                          activeSession is String &&
                          activeSession.isNotEmpty) {
                        await sessionController.endSession();
                        if (context.mounted) {
                          showPlatformDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: const Text('Session Ended'),
                                content: const Text(
                                    "Your session has been ended successfully."),
                                actions: [
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        setState(() {
                          sessionsCreated--;
                        });
                      } else {
                        if (context.mounted) {
                          showPlatformDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: const Text('No Active Session'),
                                content: const Text(
                                    "You don't have an active session to end."),
                                actions: [
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                    child: const Text('End session'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
