import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpdart/fpdart.dart';

import '../../../common/constants.dart';
import '../../../model/todo.dart';
import '../../model/task_model.dart';
import '../../provider/failure.dart';
import '../../provider/providers.dart';
import '../../provider/type_defs.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

class TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<Either<Failure, void>> addTask(Tasks task) async {
    try {
      // Check if a task with the same name already exists for the user
      final existingTaskQuery = await _task
          .where('uid', isEqualTo: task.uid)
          .where('title', isEqualTo: task.title)
          .get();

      if (existingTaskQuery.docs.isNotEmpty) {
        // A task with the same name already exists for the user
        return left(Failure('Task with the same name already exists.'));
      }

      // No duplicate task found, proceed with adding the new task
      await _task.doc(task.id).set(task.toMap());
      return right(unit);
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Tasks>> fetchUserTasks(String uid) {
    return _task
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap<List<Tasks>>((snapshot) async {
      try {
        final tasks = snapshot.docs
            .map((doc) => Tasks.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        return tasks;
      } catch (e) {
        // Handle errors and return an empty list in case of an error
        print('Error in mapping tasks: $e');
        return [];
      }
    });
  }

  FutureVoid deleteTask(Tasks task) async {
    try {
      return right(_task.doc(task.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<Tasks> fetchTaskById(String id) {
    try {
      return _task.doc(id).snapshots().map(
          (snapshot) => Tasks.fromMap(snapshot.data() as Map<String, dynamic>));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateTasksWithSubTask(Tasks tasks, String subTaskTitle) async {
    try {
      // Update the document in Firestore
      await _task.doc(tasks.id).update({
        'todos': tasks.todos.map((todo) => todo.toMap()).toList(),
      });
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateTodoIsDone(Tasks task, Todo todo) async {
    try {
      final docReference =
          FirebaseFirestore.instance.collection('tasks').doc(task.id);

      // Find the index of the todo in the todos list
      int todoIndex = task.todos.indexWhere((t) => t.title == todo.title);

      // Update the todo at the specified index
      task.todos[todoIndex] = todo;

      // Update Firestore document with the modified todos list
      await docReference.update({
        'todos': task.todos.map((t) => t.toMap()).toList(),
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> updateKarma(Tasks tasks) async {
    try {
      if (tasks.todos.every((todo) => todo.isDone)) {
        // If the task is completed, increment the 'karma' field by 1
        await _task.doc(tasks.id).update({
          'karma': FieldValue.increment(1),
        });
      } else {
        // If the task is not completed, update the 'karma' field with the current value
        await _task.doc(tasks.id).update({
          'karma': tasks.karma,
        });
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Either<Failure, void>> deleteSubtaskById(
      String taskId, String subtaskId) async {
    try {
      // Fetch the task document
      final taskDoc = await _firestore
          .collection(Constants.tasksCollection)
          .doc(taskId)
          .get();

      if (taskDoc.exists) {
        // Get the current tasks data
        Map<String, dynamic> tasksData = taskDoc.data() as Map<String, dynamic>;

        // Remove the subtask from the todos list
        tasksData['todos'] = tasksData['todos']
            .where((todo) => todo['id'] != subtaskId)
            .toList();

        // Update the Firestore document with the modified todos list
        await _firestore
            .collection(Constants.tasksCollection)
            .doc(taskId)
            .update({
          'todos': tasksData['todos'],
        });
      }

      return right(unit);
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<void> deleteSubtaskByIdOld(String taskId, String subtaskId) async {
    try {
      final docReference =
          _firestore.collection(Constants.tasksCollection).doc(taskId);

      // Get the current tasks document
      final tasksDoc = await docReference.get();

      if (tasksDoc.exists) {
        // Convert the Firestore document data to a map
        Map<String, dynamic> tasksData =
            tasksDoc.data() as Map<String, dynamic>;

        // Find the index of the subtask with the given ID in the todos list
        int subtaskIndex =
            tasksData['todos'].indexWhere((todo) => todo['id'] == subtaskId);

        if (subtaskIndex != -1) {
          // Remove the subtask from the todos list
          tasksData['todos'].removeAt(subtaskIndex);

          // Update Firestore document with the modified todos list
          await docReference.update({
            'todos': tasksData['todos'],
          });
        }
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  CollectionReference get _task =>
      _firestore.collection(Constants.tasksCollection);
}