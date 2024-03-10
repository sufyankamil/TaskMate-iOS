import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpdart/fpdart.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/auth/controller/auth_controller.dart';
import 'package:task_mate/collaboration/repository/session_repository.dart';
import 'package:task_mate/common/constants.dart';
import 'package:task_mate/model/session_model.dart';
import 'package:task_mate/model/session_todo_model.dart';
import 'package:task_mate/provider/failure.dart';
import 'package:uuid/uuid.dart';

final addTaskInSessionProvider =
    StateNotifierProvider.autoDispose<SessionController, bool>((ref) {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return SessionController(
    sessionRepository: sessionRepository,
    ref: ref,
  );
});

final sessionControllerProvider =
    StateNotifierProvider.autoDispose<SessionController, bool>((ref) {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return SessionController(
    ref: ref,
    sessionRepository: sessionRepository,
  );
});

final userSessionTask = StreamProvider.autoDispose<List<Session>>((ref) {
  final sessionController = ref.watch(sessionControllerProvider.notifier);
  return sessionController.fetchSessionWithTask();
});

final userSessionsProvider = StreamProvider.autoDispose<List<Session>>((ref) {
  final sessionController = ref.watch(sessionControllerProvider.notifier);

  return sessionController.fetchSessionsForUser();
});

final sessionCounterProvider =
    StateNotifierProvider<SessionCounter, List<Session>>((ref) {
  return SessionCounter();
});

class SessionCounter extends StateNotifier<List<Session>> {
  SessionCounter() : super([]) {
    _subscription = _controller.stream.listen((sessions) {
      state = sessions;
      saveSessionsToPrefs(state);
    });
  }

  late StreamController<List<Session>> _controller;
  late StreamSubscription<List<Session>> _subscription;

  static const String sessionListKey = 'sessionList';

  void setSessions(List<Session> sessions) {
    _controller.add(sessions);
  }

  void addSession(Session session) {
    state = [...state, session];
    saveSessionsToPrefs(state);
    _controller.add(state);
  }

  void removeSession(String sessionId) {
    state = state.where((session) => session.id != sessionId).toList();
    saveSessionsToPrefs(state);
    _controller.add(state);
  }

  Future<void> loadSessionsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedSessions = prefs.getStringList(sessionListKey);

    if (storedSessions != null) {
      final sessions = storedSessions
          .map((sessionString) => Session.fromMap(json.decode(sessionString)))
          .toList();
      _controller.add(sessions);
    }
  }

  Future<void> saveSessionsToPrefs(List<Session> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionStrings =
        sessions.map((session) => json.encode(session.toMap())).toList();
    prefs.setStringList(sessionListKey, sessionStrings);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.close();
    super.dispose();
  }
}

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
      final id = const Uuid().v1();
      // Create a new session model
      Session sessionModel = Session(
        id: id,
        ownerId: _ref.read(userProvider)?.uid ?? '',
        sessionCreatedAt: Timestamp.fromDate(DateTime.now()),
        endedAt: '',
        usersJoined: [],
        title: '',
        description: '',
        date: '',
        time: '',
        status: '',
        isPremium: false,
        isCollaborative: false,
      );

      if (kDebugMode) {
        print(sessionModel.toMap());
      }
      // Set loading to true when starting the operation
      state = true;

      dynamic activeSession = await SessionManager().get("activeSession");

      String sessionId =
          await _sessionRepository.createNewSession(sessionModel);

      // Set loading to false after the operation completes
      state = false;

      // Set the active session in the session manager
      await SessionManager().set(Constants.activeSession, sessionId);

      // Set a timer for 1 hour
      Timer(const Duration(hours: 1), () async {
        // Remove the active session after 1 hour
        await SessionManager().remove(Constants.activeSession);
        if (context.mounted) {
          showPlatformDialog(
            context: context,
            builder: (_) => BasicDialogAlert(
              title: const Text(Constants.sessionExpired),
              content: const Text(
                Constants.sessionExpiredContent,
                textAlign: TextAlign.center,
              ),
              actions: [
                BasicDialogAction(
                  title: const Text(Constants.ok),
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
      state = false;
      rethrow;
    }
  }

  // Function to end the session
  Future<void> endSession() async {
    try {
      // Ensure there is an active session
      dynamic activeSession =
          await SessionManager().get(Constants.activeSession);
      if (activeSession != null &&
          activeSession is String &&
          activeSession.isNotEmpty) {
        // Call the repository function to end the session
        await _sessionRepository.endSession(activeSession);

        // Remove the active session from the session manager
        await SessionManager().remove(Constants.activeSession);
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

  Future<Either<Failure, void>> updateSessionTask(
    Session session,
    String title,
    String description,
    String date,
    String time,
    String status,
    String sessionId,
  ) async {
    try {
      // Create a new Session Todo to the existing task list
      SessionTodo newSessionTask = SessionTodo(
        id: const Uuid().v1(),
        uid: _ref.read(userProvider)?.uid ?? '',
        title: title,
        description: description,
        date: date,
        time: time,
        status: status,
        isPending: true,
        isCompleted: false,
      );

      if (kDebugMode) {
        print(newSessionTask.toMap());
      }

      // Add the new task to the existing task list
      session = session.copyWith(tasks: [...session.tasks, newSessionTask]);

      await Future.delayed(const Duration(seconds: 1));

      // Update the document in Firestore
      await _sessionRepository.updateTaskToSession(
          session, title, description, date, time, status, sessionId);

      Fluttertoast.showToast(
          msg: Constants.taskAddedSuccessfully,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green,
          fontSize: 16.0);

      // return a success message
      return right(unit);
    } on FirebaseException catch (e) {
      // Handle Firebase exceptions
      return left(Failure(e.message!));
    } catch (e) {
      // Handle other exceptions
      return left(Failure(e.toString()));
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
          msg: Constants.sessionLeft,
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

    // Performimg asynchronous operation
    try {
      final ownerId = await sessionRepository.getOwnerId(sessionId!);
      return ownerId;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting owner ID: $e');
      }
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

  Stream<List<Session>> fetchSessionWithTask() {
    final ownerId = _ref.read(userProvider)?.uid ?? '';
    return _sessionRepository.fetchSessionWithTask(ownerId);
  }

  // Function to get session todos
  Future<List<SessionTodo>> getSessionTodos(String sessionId) async {
    try {
      // Call the repository function to get the session todos
      List<Map<String, dynamic>> todosData =
          await _sessionRepository.getSessionTodos(sessionId);

      // Convert the List<Map<String, dynamic>> to List<SessionTodo>
      List<SessionTodo> sessionTodos =
          todosData.map((todo) => SessionTodo.fromMap(todo)).toList();

      return sessionTodos;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting session todos: $e');
      }
      rethrow;
    }
  }

  Stream<List<Session>> fetchSessionsForUser() {
    try {
      final ownerId = _ref.read(userProvider)?.uid ?? '';

      final result = _sessionRepository.fetchSessions(ownerId);

      return result;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching sessions for user: $e");
      }
      rethrow;
    }
  }

  void updateAddTask({
    required BuildContext context,
    required String sessionId,
    required String title,
    String? description,
    String? date,
    String? time,
  }) async {
    if (!mounted) {
      return;
    }
    state = true;

    final uid = _ref.read(userProvider)?.uid ?? '';

    try {
      final Session sessionsData = Session(
        id: sessionId,
        ownerId: uid,
        sessionCreatedAt: Timestamp.fromDate(DateTime.now()),
        endedAt: '',
        tasks: [],
        usersJoined: [],
        title: title,
        description: description ?? '',
        date: date ?? '',
        time: time ?? '',
        status: '',
        isPremium: false,
        isCollaborative: false,
      );

      if (kDebugMode) {
        print(sessionsData.toMap());
      }

      final result = await _sessionRepository.updateAddTask(sessionsData);

      if (!mounted) {
        return; // Widget is not mounted, avoid updating the state
      }

      state = false;

      result.fold(
        (failure) => Fluttertoast.showToast(msg: failure.message),
        (_) {
          Fluttertoast.showToast(msg: Constants.sessionTaskUpdated);
          Routemaster.of(context).pop();
        },
      );
    } catch (e) {
      if (!mounted) {
        return; // Widget is not mounted, avoid updating the state
      }
      state = false;
      if (kDebugMode) {
        print('Error in addTask: $e');
      }
      Fluttertoast.showToast(msg: Constants.sessionTaskUpdateFailed);
    }
  }
}
