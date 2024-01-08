import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpdart/fpdart.dart';
import 'package:task_mate/provider/providers.dart';

import '../../common/constants.dart';
import '../../model/session_model.dart';
import '../../model/session_task_model.dart';
import '../../provider/failure.dart';

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

  Future<String> createNewSession(Session sessionModel) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw Exception("User not authenticated");
      }

      // Create a new session document in Firestore
      DocumentReference sessionRef =
          await _userSession.add(sessionModel.toMap());

      return sessionRef.id; // Return the session ID
    } catch (e) {
      if (kDebugMode) {
        print("Error creating new session: $e");
      }
      rethrow;
    }
  }

  // Function to end the session and update the 'endedAt' timestamp
  Future<void> endSession(String sessionId) async {
    try {
      // Get the reference to the session document
      DocumentReference sessionDocRef = _userSession.doc(sessionId);

      // Update the 'endedAt' field with the current timestamp
      await sessionDocRef.update({
        'endedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error ending session: $e");
      }
      rethrow;
    }
  }

  Future<bool> checkSessionExists(String sessionId) async {
    try {
      DocumentSnapshot sessionSnapshot =
          await _userSession.doc(sessionId).get();

      return sessionSnapshot.exists;
    } catch (e) {
      // Handle error or rethrow as needed
      rethrow;
    }
  }

  Future<bool> joinSession(String sessionId, String userEmail) async {
    try {
      // Check if the session exists
      bool sessionExists = await checkSessionExists(sessionId);

      if (sessionExists) {
        // Add the user's email to the 'usersJoined' field
        await _userSession.doc(sessionId).update({
          'usersJoined': FieldValue.arrayUnion([userEmail]),
        });

        if (kDebugMode) {
          print('Successfully joined session with ID: $sessionId');
        }
      } else {
        if (kDebugMode) {
          print('Session with ID $sessionId does not exist');
        }
      }

      return sessionExists;
    } catch (e) {
      if (kDebugMode) {
        print('Error joining session: $e');
      }
      rethrow;
    }
  }

  Future<void> updateTaskToSession(
    Session session,
    String title,
    String description,
    String date,
    String time,
    String status,
    String sessionId, 
  ) async {
    try {
      // Update the document in Firestore
      await _userSession.doc(sessionId).update({
        'todos': session.tasks.map((e) => e.toMap()).toList(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        // Handle document not found exception
        if (kDebugMode) {
          print('Document not found: ${session.id}');
        }
        Fluttertoast.showToast(msg: 'Document not found');
      } else {
        // Handle other exceptions
        if (kDebugMode) {
          print('Error updating task to session: $e');
        }
        Fluttertoast.showToast(msg: e.toString());
      }
    } catch (e) {
      // Handle other exceptions
      if (kDebugMode) {
        print('Error updating task to session: $e');
      }
      Fluttertoast.showToast(msg: e.toString());
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

  Stream<List<String>> getUsersInSession(String sessionId) {
    try {
      return _userSession.doc(sessionId).snapshots().map((docSnapshot) {
        if (docSnapshot.exists) {
          final List<dynamic>? usersData = docSnapshot['usersJoined'];

          if (usersData != null) {
            final List<String> users =
                usersData.map((user) => user.toString()).toList();

            return users;
          }
        }

        return <String>[];
      }).handleError((error) {
        if (kDebugMode) {
          print("Error fetching users in session: $error");
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching users in session: $e");
      }
      rethrow;
    }
  }

  // Function to leave the session
  Future<void> leaveSession(String sessionId, String userEmail) async {
    try {
      // Get the reference to the session document
      DocumentReference sessionDocRef = _userSession.doc(sessionId);

      // Remove the user's email from the 'usersJoined' field
      await sessionDocRef.update({
        'usersJoined': FieldValue.arrayRemove([userEmail]),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error leaving session: $e");
      }
      rethrow;
    }
  }

  // Function to get the owner id fromm session
  Future<String?> getOwnerId(String sessionId) async {
    try {
      DocumentSnapshot sessionSnapshot =
          await _userSession.doc(sessionId).get();

      if (sessionSnapshot.exists) {
        return sessionSnapshot['ownerId'];
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting owner id: $e");
      }
      rethrow;
    }
  }

  // Function to fetch the session details from session ID
  Future<Session?> getSessionDetails(String sessionId) async {
    try {
      DocumentSnapshot sessionSnapshot =
          await _userSession.doc(sessionId).get();

      if (sessionSnapshot.exists) {
        return Session.fromMap(sessionSnapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting session details: $e");
      }
      rethrow;
    }
  }

  // Function to start the timer as soon as the user joined the session
  Future<void> startTimer(String sessionId) async {
    try {
      // Get the reference to the session document
      DocumentReference sessionDocRef = _userSession.doc(sessionId);

      // Update the 'startedAt' field with the current timestamp
      await sessionDocRef.update({
        'startedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error starting timer: $e");
      }
      rethrow;
    }
  }
}
