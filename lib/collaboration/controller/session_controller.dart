import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_mate/auth/controller/auth_controller.dart';
import 'package:task_mate/collaboration/repository/session_repository.dart';
import 'package:task_mate/model/session_model.dart';
import 'package:uuid/uuid.dart';
import '../../model/session_task_model.dart';

final sessionControllerProvider =
    StateNotifierProvider.autoDispose<SessionController, bool>((ref) {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return SessionController(
    ref: ref,
    sessionRepository: sessionRepository,
  );
});

// final sessionIdProvider = StateProvider<String?>((ref) => null);

// final usersInSessionProvider = StreamProvider<List<String>>((ref) {
//   final sessionId = ref.watch(sessionIdProvider);
//   final sessionRepository = ref.watch(sessionRepositoryProvider);

//   print(sessionId);
//   print(sessionRepository);

//   // Return the stream of users who have joined the session
//   return sessionId != null
//       ? sessionRepository.getUsersInSession(sessionId)
//       : Stream.value([]); // Return an empty list if the session ID is null
// });

class SessionIdController extends StateNotifier<String?> {
  SessionIdController() : super(null);

  void setSessionId(String sessionId) {
    state = sessionId;
  }
}

final sessionIdProvider =
    StateNotifierProvider<SessionIdController, String?>((ref) {
  return SessionIdController();
});

final usersInSessionProvider = StreamProvider<List<String>>((ref) {
  final sessionId = ref.watch(sessionIdProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);

  // Return the stream of users who have joined the session
  return sessionId != null
      ? sessionRepository.getUsersInSession(sessionId)
      : Stream.value([]); // Return an empty list if the session ID is null
});

class SessionController extends StateNotifier<bool> {
  final Ref _ref;
  final SessionRepository _sessionRepository;

  SessionController(
      {required Ref ref, required SessionRepository sessionRepository})
      : _ref = ref,
        _sessionRepository = sessionRepository,
        super(false);

  Future<String> createNewSession(BuildContext context) async {
    try {
      final id = const Uuid().v4();
      // Create a new session model
      Session sessionModel = Session(
        id: id,
        ownerId: _ref.read(userProvider)?.uid ?? '',
        createdAt: Timestamp.now(),
        endedAt: '',
        tasks: [],
        usersJoined: [],
      );
      // Set loading to true when starting the operation
      state = true;

      dynamic activeSession = await SessionManager().get("activeSession");

      String sessionId =
          await _sessionRepository.createNewSession(sessionModel);

      // Set loading to false after the operation completes
      state = false;

      // Set the active session in the session manager
      await SessionManager().set('activeSession', sessionId);

      // Set a timer for 1 hour
      Timer(const Duration(hours: 1), () async {
        // Remove the active session after 1 hour
        await SessionManager().remove('activeSession');
        if (context.mounted) {
          showPlatformDialog(
            context: context,
            builder: (_) => BasicDialogAlert(
              title: const Text("Session Expired"),
              content: const Text(
                  "Your session has expired. Please create a new session to continue."),
              actions: [
                BasicDialogAction(
                  title: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        }
      });

      return sessionId;
    } catch (e) {
      // Handle error or rethrow as needed
      // Set loading to false in case of an error
      state = false;
      rethrow;
    }
  }

  // Function to end the session
  Future<void> endSession() async {
    try {
      // Ensure there is an active session
      dynamic activeSession = await SessionManager().get("activeSession");
      if (activeSession != null &&
          activeSession is String &&
          activeSession.isNotEmpty) {
        // Call the repository function to end the session
        await _sessionRepository.endSession(activeSession);

        // Remove the active session from the session manager
        await SessionManager().remove('activeSession');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error ending session: $e");
      }
      rethrow;
    }
  }

  Future<bool> joinSession(String sessionId, String userEmail) async {
    try {
      // Set loading to true when starting the operation
      state = true;

      bool sessionExists =
          await _sessionRepository.checkSessionExists(sessionId);

      if (sessionExists) {
        // Call the repository function to join the session with the user's email
        await _sessionRepository.joinSession(sessionId, userEmail);

        // Perform actions to join the session (if needed)
        if (kDebugMode) {
          print('Successfully joined session with ID: $sessionId');
        }
      } else {
        // Handle case where the session does not exist
        if (kDebugMode) {
          print('Session with ID $sessionId does not exist');
        }
      }

      // Set loading to false after the operation completes
      state = false;

      // Return the actual result based on session existence
      return sessionExists;
    } catch (e) {
      state = false;
      if (kDebugMode) {
        print('Error joining session: $e');
      }
      rethrow;
    }
  }

  Future<void> addTaskToSession({
    required String title,
    required String description,
    required String date,
    required String time,
    required String status,
  }) async {
    state = true;

    try {
      // Use a valid sessionId (replace this with your logic)
      String sessionId = const Uuid().v4();

      final uid = _ref.read(userProvider)?.uid ?? '';

      final SessionTasks sessionTasks = SessionTasks(
        id: sessionId,
        ownerId: uid,
        title: title,
        description: description,
        date: date,
        time: time,
        status: status,
      );

      // Ensure sessionId is not null or empty before calling addTaskToSession
      if (sessionId.isNotEmpty) {
        await _sessionRepository.addTaskToSession(sessionId, sessionTasks);
      } else {
        throw Exception("Invalid sessionId");
      }

      state = false;
    } catch (e) {
      if (kDebugMode) {
        print("Error adding task to session: $e");
      }
      // Handle error or rethrow as needed
      // rethrow;
    }
  }

  void fetchSessionTasks(String sessionId) {
    try {
      _sessionRepository.getSessionTasks(sessionId).listen((tasks) {
        // Handle session tasks as needed
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching session tasks: $e");
      }
      rethrow;
    }
  }

  Stream<List<String>> fetchUsersInSession(String sessionId) {
    try {
      return _sessionRepository
          .getUsersInSession(sessionId)
          .asBroadcastStream();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching users in session: $e");
      }
      rethrow;
    }
  }

  Future<void> leaveSession(String sessionId, String userEmail) async {
    try {
      // Set loading to true when starting the operation
      state = true;

      // Call the repository function to leave the session with the user's email
      await _sessionRepository.leaveSession(sessionId, userEmail);

      // Perform actions to leave the session (if needed)
      if (kDebugMode) {
        print('Successfully left session with ID: $sessionId');
      }
      Fluttertoast.showToast(
          msg: "Successfully left the session",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: const Color(0xFF5A5A5A),
          fontSize: 16.0);

      // Set loading to false after the operation completes
      state = false;
    } catch (e) {
      state = false;
      if (kDebugMode) {
        print('Error leaving session: $e');
      }
      rethrow;
    }
  }

  // Function to get owner ID
  Future<String?> getOwnerId(String sessionId) async {
    try {
      // Set loading to true when starting the operation
      state = true;

      // Call the repository function to get the owner ID
      String? ownerId = await _sessionRepository.getOwnerId(sessionId);

      // Set loading to false after the operation completes
      state = false;

      // Return the owner ID
      return ownerId;
    } catch (e) {
      state = false;
      if (kDebugMode) {
        print('Error getting owner ID: $e');
      }
      rethrow;
    }
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

  // Function to get session details from session ID
  Future<Session?> getSessionDetails(String sessionId) async {
    try {
      // Set loading to true when starting the operation
      state = true;

      // Call the repository function to get the session details
      Session? sessionDetails =
          await _sessionRepository.getSessionDetails(sessionId);

      // Set loading to false after the operation completes
      state = false;

      // Return the session details
      return sessionDetails;
    } catch (e) {
      state = false;
      if (kDebugMode) {
        print('Error getting session details: $e');
      }
      rethrow;
    }
  }
}
