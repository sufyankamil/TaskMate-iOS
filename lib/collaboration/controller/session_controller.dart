import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<String> createNewSession() async {
    try {
      // Set loading to true when starting the operation
      state = true;

      String sessionId = await _sessionRepository.createNewSession();

      // Set loading to false after the operation completes
      state = false;

      return sessionId;
    } catch (e) {
      // Handle error or rethrow as needed
      // Set loading to false in case of an error
      state = false;
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
