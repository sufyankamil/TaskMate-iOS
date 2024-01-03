import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:routemaster/routemaster.dart';
import 'package:task_mate/auth/controller/auth_controller.dart';
import 'package:task_mate/collaboration/repository/session_repository.dart';
import 'package:uuid/uuid.dart';
import '../../model/session_model.dart';

final sessionControllerProvider =
    StateNotifierProvider.autoDispose<SessionController, bool>((ref) {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return SessionController(
    ref: ref,
    sessionRepository: sessionRepository,
  );
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
      // Set loading to true when starting the operation
      state = true;

      dynamic activeSession = await SessionManager().get("activeSession");

      String sessionId = await _sessionRepository.createNewSession();

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

  Future<void> joinSession(String sessionId) async {
    try {
      // Set loading to true when starting the operation
      state = true;

      // Use the session ID to fetch session details or perform necessary actions
      // For example, you can check if the session exists and then proceed accordingly
      bool sessionExists =
          await _sessionRepository.checkSessionExists(sessionId);

      if (sessionExists) {
        // Perform actions to join the session
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
}
