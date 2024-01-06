import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:routemaster/routemaster.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../../auth/controller/auth_controller.dart';
import '../../model/session_model.dart';
import '../controller/session_controller.dart';
import '../repository/session_repository.dart';

class SessionJoined extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionJoined({super.key, required this.sessionId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SessionJoinedState();
}

class _SessionJoinedState extends ConsumerState<SessionJoined> {
  TextEditingController sessionIdController = TextEditingController();

  void navigateToSessionCreation() {
    Routemaster.of(context).push('/');
  }

  List<String> usersList = [];

  String? ownerId = '';

  Future<void> fetchOwnerId() async {
    final sessionController = ref.watch(sessionControllerProvider.notifier);

    ownerId = await sessionController.getOwnerId(widget.sessionId);
  }

  final ownerIdProvider = FutureProvider<String?>((ref) async {
    final sessionRepository = ref.read(sessionRepositoryProvider);
    final sessionId = ref.read(sessionIdProvider);

    // Perform the asynchronous operation
    try {
      final ownerId = await sessionRepository.getOwnerId(sessionId!);
      return ownerId;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting owner ID: $e');
      }
      // Optionally, you can rethrow the error or return a default value.
      return null;
    }
  });

  // Function to fetch session details
  Future<void> fetchSessionDetails() async {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final sessionController = ref.watch(sessionControllerProvider.notifier);
      Session? sessionDetails =
          await sessionController.getSessionDetails(widget.sessionId);

      if (sessionDetails != null) {
        ownerId = sessionDetails.ownerId;
      }
    });
  }

  void showSuccessMessage() {
    Fluttertoast.showToast(
      msg: 'Session joined successfully',
      backgroundColor: Colors.green,
      timeInSecForIosWeb: 4,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchSessionDetails();
    showSuccessMessage();
  }

  @override
  Widget build(BuildContext context) {
    final sessionController = ref.watch(sessionControllerProvider.notifier);

    final Stream<List<String>> sessions =
        sessionController.fetchUsersInSession(widget.sessionId);

    final userId = ref.read(userProvider)?.uid ?? '';

    final isOwner = ownerId == userId;

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
                        child: isOwner
                            ? const Text(
                                'End Session',
                                style: TextStyle(color: Colors.red),
                              )
                            : const Text(
                                'Leave Session',
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
                  Future.delayed(Duration.zero, () {
                    setState(() {
                      usersList = snapshot.data ?? [];
                    });
                  });

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
            ],
          );
        }
      },
    );
  }

  Future<dynamic> endSessionMethod(
    BuildContext context,
  ) async {
    final sessionController = ref.watch(sessionControllerProvider.notifier);

    // ownerId = await sessionController.getOwnerId(widget.sessionId);

    // final userId = ref.read(userProvider)?.uid ?? '';

    // final isOwner = ownerId == userId;

    // ignore: use_build_context_synchronously
    return showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: const Text('Leave Session'),
        content: const Text('Are you sure you want to leave the session?'),
        actions: [
          BasicDialogAction(
            title: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          BasicDialogAction(
            title: const Text('Leave Session'),
            onPressed: () {
              sessionController.endSession();
              Navigator.pop(context);
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Session left successfully',
                backgroundColor: Colors.green,
              );
              navigateToSessionCreation();
            },
          ),
        ],
      ),
    );
  }

  Future<dynamic> leaveSessionMethod(
      BuildContext context, int userIndex) async {
    final sessionController = ref.watch(sessionControllerProvider.notifier);

    ownerId = await sessionController.getOwnerId(widget.sessionId);

    final userId = ref.read(userProvider)?.uid ?? '';

    final isOwner = ownerId == userId;

    void leaveSessionForCurrentUser(int userIndex) async {
      final sessionController = ref.watch(sessionControllerProvider.notifier);
      final String? currentUserUid = ref.read(userProvider)?.uid;

      if (currentUserUid != null) {
        await sessionController.leaveSession(widget.sessionId, currentUserUid);
        Navigator.pop(context);
        Navigator.pop(context);
        navigateToSessionCreation();
      } else {
        // Handle the case where the current user's UID is null
        print("Current user UID is null");
      }
    }

    // Check if the user is the owner
    if (isOwner) {
      // Perform actions for the owner (e.g., end session)
      sessionController.endSession();
      Navigator.pop(context);
      Navigator.pop(context);
      navigateToSessionCreation();
    } else {
      // Perform actions for non-owner (e.g., leave session)
      leaveSessionForCurrentUser(userIndex);
    }
  }
}
