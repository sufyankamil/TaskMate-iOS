import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:task_mate/collaboration/controller/session_controller.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../../model/session_model.dart';

final sessionsCreatedProvider =
    StateNotifierProvider<SessionCounter, List<Session>>((ref) {
  return SessionCounter();
});

class SessionCounter extends StateNotifier<List<Session>> {
  SessionCounter() : super([]);

  void setSessions(List<Session> sessions) {
    state = sessions;
  }

  void addSession(Session session) {
    state = [...state, session];
  }

  void removeSession(String sessionId) {
    state = state.where((session) => session.id != sessionId).toList();
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
  late String sessionId;

  @override
  void initState() {
    super.initState();
    sessionId = '';
    setSession();
  }

  void navigateToSessionCreation(dynamic activeSession) {
    Routemaster.of(context).push('/session-joined/$activeSession');
  }

  setSession() async {
    dynamic activeSession = await SessionManager().get("activeSession");
    print('Active Session: $activeSession');

    if (activeSession != null &&
        activeSession is String &&
        activeSession.isNotEmpty) {
      navigateToSessionCreation(activeSession);
    } else {
      await SessionManager().set("activeSession", sessionId);
    }
  }

  void navigateToSessionJoined(BuildContext context, String sessionId) {
    Routemaster.of(context).push('/session-joined/$sessionId');
  }

  @override
  Widget build(BuildContext context) {
    final sessionController = ref.watch(sessionControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                startSessionButton(context, sessionId, sessionController),
                const Spacer(),
                endSessionButton(sessionController, context),
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
                    sessionTextFormFIeld(ref);
                  },
                  child: const Text('Enter session ID'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            activeSessions(ref),
          ],
        ),
      ),
    );
  }

  ElevatedButton startSessionButton(
      BuildContext context, sessionId, SessionController sessionController) {
    return ElevatedButton(
      onPressed: () async {
        // Create a new session
        dynamic activeSession = await SessionManager().get("activeSession");

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
          String newSessionId =
              await sessionController.createNewSession(context);

          setState(() {
            sessionId = newSessionId;
          });

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
    );
  }

  //////

  activeSessions(WidgetRef ref) {
    final userSessions = ref.watch(userSessionsProvider);

    List<String> sessionIdss = [];

    final userSessionsData = userSessions.maybeWhen(
      data: (data) {
        print('Data: $data');
        final sessionIds = data.map((session) => session.id).toList();

        final createdAt = data.map((session) => session.createdAt).toList();
        sessionIdss = sessionIds;
        print('Session IDs: $sessionIdss');

        return data;
      },
      loading: () => null,
      error: (e, s) => null,
      orElse: () => null,
    );

    if (userSessionsData != null) {
      // Save the number of tasks in the notificationCount variable
      sessionsCreated = userSessionsData.length;
    } else if (userSessions.error != null) {
      // Handle error state here if necessary
      if (kDebugMode) {
        print('Error State in recent: ${userSessions.error}');
      }
    } else {
      // Handle loading state here if necessary
      if (kDebugMode) {
        print('Loading State');
      }
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(3.0.widthPercent),
          child: const Text(
            'Recently joined sessions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(3.0),
          child: Divider(),
        ),
        if (userSessionsData == null)
          const Center(
            child: CircularProgressIndicator.adaptive(),
          )
        else if (userSessionsData.isEmpty)
          const Center(
            child: Text('No sessions found'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            itemCount: userSessionsData.length,
            itemBuilder: (context, index) {
              
              Session session = userSessionsData[index];
              String sessionId = session.id;
              DateTime createdDateTime = session.createdAt.toDate();

              String formattedDate =
                  DateFormat('dd-MM-yyyy HH:mm:ss').format(createdDateTime);

              return ListTile(
                leading: const Icon(Icons.circle, color: Colors.green),
                title: Text('Session ID: $sessionId',
                    softWrap: true, style: const TextStyle(fontSize: 13)),
                subtitle: Text('Created on: $formattedDate'),
                trailing: const Text('2', style: TextStyle(fontSize: 18)),
              );
            },
          ),
      ],
    );
  }

  ElevatedButton endSessionButton(
      SessionController sessionController, BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        dynamic activeSession = await SessionManager().get("activeSession");

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
                  content:
                      const Text("Your session has been ended successfully."),
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
          if (context.mounted) {
            showPlatformDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: const Text('No Active Session'),
                  content:
                      const Text("You do not have an active session to end."),
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
                  print('Session ID: $sessionId');
                  bool result =
                      await sessionController.joinSession(sessionId, userEmail);

                  Navigator.pop(context);

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
