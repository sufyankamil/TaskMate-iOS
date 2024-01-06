import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:routemaster/routemaster.dart';
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

  void navigateToSessionJoined(BuildContext context, String sessionId) {
    Routemaster.of(context).push('/session-joined/$sessionId');
  }

  @override
  Widget build(BuildContext context) {
    final sessionController = ref.watch(sessionControllerProvider.notifier);

    String sessionId = '';


    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
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
                                  "You already have an active session. Please end the current session to create a new one.",
                                ),
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

                        _showSessionCreationSuccess(context, sessionId);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Start Session',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
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
                                    "You do not have an active session to end."),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('End Session',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have a session ID?', style: TextStyle()),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () async {
                      // Get the session ID from the user

                      sessionTextFormFIeld(ref);
                    },
                    child: const Text('Enter session ID'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSessionCreationSuccess(
      BuildContext context, String sessionId) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Session Created'),
          content: Text("Your session ID is: $sessionId"),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                _showLoadingIndicator(context, sessionId);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLoadingIndicator(
      BuildContext context, String sessionId) async {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return const CupertinoAlertDialog(
          content: Column(
            children: [
              CircularProgressIndicator.adaptive(),
              SizedBox(height: 10),
              Text('Setting things up...'),
            ],
          ),
        );
      },
    );

    // Simulate some delay to show the loading indicator
    Future.delayed(Duration.zero);

    // Dismiss the loading dialog
    Navigator.pop(context);

    // Introduce a slight delay before navigating to the next screen
    Future.delayed(const Duration(milliseconds: 500));

    // Now, navigate to the JoinedSession screen
    navigateToSessionJoined(context, sessionId);
  }

  sessionTextFormFIeld(WidgetRef ref) {
    final TextEditingController sessionTextController = TextEditingController();

    final TextEditingController emailTextController = TextEditingController();

    final sessionController = ref.watch(sessionControllerProvider.notifier);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter session ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sessionTextController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Session ID',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailTextController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Get the session ID & email from the user
                String sessionId = sessionTextController.text;

                String userEmail = emailTextController.text;

                if (sessionId.isNotEmpty && userEmail.isNotEmpty) {
                  bool result =
                      await sessionController.joinSession(sessionId, userEmail);

                  if (result) {
                    if (context.mounted) {
                      _showLoadingIndicator(context, sessionId);
                    }
                  } else {
                    if (context.mounted) {
                      showPlatformDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: const Text('Session ID is invalid'),
                            content: const Text(
                                "Please enter a valid session ID to join."),
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
                } else {
                  if (context.mounted) {
                    showPlatformDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: const Text('Invalid details'),
                          content: const Text(
                              "Please enter a valid details to join a session."),
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
              child: const Text('Get started'),
            ),
          ],
        );
      },
    );
  }
}
