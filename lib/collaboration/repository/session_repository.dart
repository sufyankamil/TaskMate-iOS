import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_mate/provider/providers.dart';

import '../../common/constants.dart';
import '../../model/session_model.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

class SessionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SessionRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _userSession =>
      _firestore.collection(Constants.sessionCollection);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String> createNewSession() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw Exception("User not authenticated");
      }

      // Create a new session document in Firestore
      DocumentReference sessionRef = await _userSession.add({
        'ownerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'tasks': [],
      });

      return sessionRef.id; // Return the session ID
    } catch (e) {
      if (kDebugMode) {
        print("Error creating new session: $e");
      }
      rethrow; // Rethrow the exception to handle it at the calling site
    }
  }

  Future<void> addTaskToSession(String sessionId, SessionTasks task) async {
    try {
      await _userSession.doc(sessionId).update({
        'tasks': FieldValue.arrayUnion([task.toMap()]),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error adding task to session: $e");
      }
      rethrow;
    }
  }

  Stream<List<SessionTasks>> getSessionTasks(String sessionId) {
    try {
      return _userSession.doc(sessionId).snapshots().map((doc) {
        final List<dynamic>? tasksData =
            (doc.data() as Map<String, dynamic>)['tasks'];
        if (tasksData != null) {
          final List<SessionTasks> tasks = tasksData
              .map((task) => SessionTasks.fromMap(task as Map<String, dynamic>))
              .toList();
          return tasks;
        } else {
          return [];
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error getting session tasks: $e");
      }
      rethrow;
    }
  }

  Stream<List<SessionTasks>> getSessionTasksNew(String sessionId) {
    try {
      return _userSession.doc(sessionId).snapshots().map((doc) {
        final dynamic data = doc.data();
        if (data != null && data['tasks'] is List) {
          final List<dynamic> tasksData = data['tasks'];
          final List<SessionTasks> tasks = tasksData
              .whereType<Map<String, dynamic>>() // Filter out non-map items
              .map((task) => SessionTasks.fromMap(task))
              .toList();
          return tasks;
        } else {
          return [];
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error getting session tasks: $e");
      }
      rethrow;
    }
  }
}
