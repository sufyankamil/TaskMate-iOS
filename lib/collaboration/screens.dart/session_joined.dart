import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
                  const Text(
                    'Session ID',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  ListTile(
                    title: Text(
                      widget.sessionId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
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
                  // show number of users joined
                  StreamBuilder<List<String>>(
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
                            if (userCount == 0)
                              const Text('No users in session'),
                          ],
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Session Joined"),
            const SizedBox(height: 20),

            // Display the list of users who have joined the session
            // Consumer(
            //   builder: (context, watch, child) {
            //     final sessionController =
            //         ref.watch(sessionControllerProvider.notifier);

            //     final sessions = sessionController.fetchUsersInSession('');

            //     return sessions.when(
            //       data: (data) {
            //         return ListView.builder(
            //           shrinkWrap: true,
            //           itemCount: data.length,
            //           itemBuilder: (context, index) {
            //             return ListTile(
            //               title: Text(data[index]),
            //             );
            //           },
            //         );
            //       },
            //       loading: () => const CircularProgressIndicator(),
            //       error: (error, stack) => const Text('Error'),
            //     );
            //   },
            // ),

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
                      Text('Total Users Joined: $userCount'),
                      const SizedBox(height: 10),
                      if (userCount > 0)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: userCount,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(users[index]),
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
    );
  }
}
