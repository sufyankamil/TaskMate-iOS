import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/session_controller.dart';

class SessionJoined extends ConsumerStatefulWidget {
  const SessionJoined({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SessionJoinedState();
}

class _SessionJoinedState extends ConsumerState<SessionJoined> {
  TextEditingController sessionIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Session Joined"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Session Joined"),
            const SizedBox(height: 20),

            // Display the list of users who have joined the session
            Consumer(
              builder: (context, watch, child) {
                final usersInSession = ref.watch(usersInSessionProvider);
                print(usersInSession);
                return Column(
                  children: usersInSession.when(
                    data: (users) {
                      return users
                          .map((user) => Text(user))
                          .toList(); // Convert the list of users to a list of Text widgets
                    },
                    loading: () => const [
                      CircularProgressIndicator(),
                    ],
                    error: (error, stack) => [
                      Text(error.toString()),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
