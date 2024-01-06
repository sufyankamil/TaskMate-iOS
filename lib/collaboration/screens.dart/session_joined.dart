import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../controller/session_controller.dart';

class SessionJoined extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionJoined({super.key, required this.sessionId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SessionJoinedState();
}

class _SessionJoinedState extends ConsumerState<SessionJoined> {
  TextEditingController sessionIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sessionController = ref.watch(sessionControllerProvider.notifier);

    final Stream<List<String>> sessions =
        sessionController.fetchUsersInSession(widget.sessionId);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Session Joined"),
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Session ID',
                        style: TextStyle(
                            color: Colors.white, fontSize: 5.0.widthPercent),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          endSessionMethod(context);
                        },
                        child: const Text(
                          'End Session',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text(
                      widget.sessionId,
                      style: TextStyle(
                          color: Colors.white, fontSize: 3.0.widthPercent),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: widget.sessionId));
                        Fluttertoast.showToast(
                          msg: 'Session ID copied to clipboard',
                          backgroundColor: Colors.green,
                        );
                      },
                    ),
                  ),
                  countNumberOfUsers(sessions)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Users in Session',
                style:
                    TextStyle(color: Colors.white, fontSize: 5.0.widthPercent),
              ),
            ),
            StreamBuilder<List<String>>(
              stream: sessions,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return const Text('Error');
                } else {
                  final List<String> users = snapshot.data ?? [];
                  final int userCount = users.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (userCount > 0)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: userCount,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    radius: 20,
                                    child: Text('${index + 1}'),
                                  ),
                                ),
                                SizedBox(width: 8.0.widthPercent),
                                Text(users[index]),
                              ],
                            );
                          },
                        ),
                      if (userCount == 0) const Text('No users in session'),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Session Joined"),
            SizedBox(height: 20),

            // Display the list of users who have joined the session
          ],
        ),
      ),
    );
  }

  StreamBuilder<List<String>> countNumberOfUsers(
      Stream<List<String>> sessions) {
    return StreamBuilder<List<String>>(
      stream: sessions,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Fluttertoast.showToast(
            msg: 'Error getting users in session',
            backgroundColor: Colors.red,
          );
          return const Text('Error');
        } else {
          final List<String> users = snapshot.data ?? [];
          final int userCount = users.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Total Users Joined: $userCount'),
              if (userCount == 0) const Text('No users in session'),
            ],
          );
        }
      },
    );
  }

  Future<dynamic> endSessionMethod(BuildContext context) {
    return showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: const Text('End Session'),
        content: const Text('Are you sure you want to end the session?'),
        actions: [
          BasicDialogAction(
            title: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          BasicDialogAction(
            title: const Text('End Session'),
            onPressed: () {
              // sessionController.endSession(
              //     widget.sessionId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
