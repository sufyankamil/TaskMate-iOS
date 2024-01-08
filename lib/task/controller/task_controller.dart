import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpdart/fpdart.dart';

import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../common/generate_random_colors.dart';
import '../../../common/generate_random_icon.dart';
import '../../../model/task_model.dart';
import '../../../model/todo.dart';
import '../../auth/controller/auth_controller.dart';
import '../../provider/failure.dart';
import '../repository/task_repository.dart';

final postControllerProvider =
    StateNotifierProvider.autoDispose<TaskController, bool>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return TaskController(
    taskRepository: taskRepository,
    ref: ref,
  );
});

final userTaskProvider = StreamProvider.autoDispose<List<Tasks>>((ref) {
  final taskController = ref.watch(postControllerProvider.notifier);
  return taskController.fetchUserTasks();
});

final taskByIdProvider =
    StreamProvider.family.autoDispose((ref, String postId) {
  final taskController = ref.watch(postControllerProvider.notifier);
  return taskController.fetchTaskById(postId);
});

final taskControllerProvider =
    StateNotifierProvider.autoDispose<TaskController, bool>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return TaskController(
    taskRepository: taskRepository,
    ref: ref,
  );
});

class TaskController extends StateNotifier<bool> {
  final TaskRepository _taskRepository;

  final Ref _ref;

  int chipIndex = 0;

  // Use state providers for doingTodos and doneTodos
  final doingTodos = <Map<String, dynamic>>[];

  final doneTodos = <Map<String, dynamic>>[];

  final TextEditingController titleController = TextEditingController();

  TaskController({
    required TaskRepository taskRepository,
    required Ref ref,
  })  : _taskRepository = taskRepository,
        _ref = ref,
        super(false);

  void addTask({
    required BuildContext context,
    required String title,
  }) async {
    state = true;

    String taskId = const Uuid().v1();

    final Icon assignedIcon = generateRandomIcon();

    final colors = generateRandomColor();

    final uid = _ref.read(userProvider)?.uid ?? '';

    Stream<List<Tasks>> existingTasksStream =
        _taskRepository.fetchUserTasks(uid);

    // Listen to the stream and check if any existing task has the same title as the new task
    try {
      final List<Tasks> existingTasks = await existingTasksStream.first;

      if (existingTasks
          .any((Tasks existingTask) => existingTask.title == title)) {
        state = false;
        Fluttertoast.showToast(msg: 'Task with the same name already exists.');
        return;
      } else {
        final Tasks tasks = Tasks(
          id: taskId,
          title: title,
          color: colors.value.toRadixString(16).padLeft(8, '0'),
          createdAt: DateTime.now(),
          uid: uid,
          isPending: true,
          isCompleted: false,
        );

        if (kDebugMode) {
          print(tasks.toMap());
        }

        final result = await _taskRepository.addTask(tasks);

        state = false;

        result.fold(
          (failure) => Fluttertoast.showToast(msg: failure.message),
          (_) {
            Fluttertoast.showToast(msg: 'Task Added Successfully');
            Routemaster.of(context).pop();
          },
        );
      }
    } catch (e) {
      state = false;
      if (kDebugMode) {
        print('Error in addTask: $e');
      }
    }
  }

  void changeChipIndex(int index) {
    chipIndex = index;
  }

  Stream<List<Tasks>> fetchUserTasks() {
    final uid = _ref.read(userProvider)?.uid ?? '';
    return _taskRepository.fetchUserTasks(uid);
  }

  Stream<Tasks> fetchTaskById(String taskId) {
    return _taskRepository.fetchTaskById(taskId);
  }

  Future<Either<Failure, void>> updateTasksWithSubTask(
    Tasks tasks,
    String subTaskTitle,
  ) async {
    try {
      // Create a new Todo object with the provided title
      Todo newSubTask = Todo(
        id: const Uuid().v1(),
        title: subTaskTitle,
        isDone: false,
      );

      print('Document found above: ${tasks.id}');

      print(newSubTask.toMap());

      // Add the new subtask to the existing todos list
      tasks = tasks.copyWith(todos: [...tasks.todos, newSubTask]);

      print('-------');

      print(tasks);

      // Update the document in Firestore
      await _taskRepository.updateTasksWithSubTask(tasks, subTaskTitle);

      Fluttertoast.showToast(msg: 'Sub Task Added Successfully');

      // Return a successful result
      return right(unit);
    } on FirebaseException catch (e) {
      // Handle Firebase exceptions
      return left(Failure(e.message!));
    } catch (e) {
      // Handle other exceptions
      return left(Failure(e.toString()));
    }
  }

  Future<void> updateTodoIsDone(Tasks task, Todo todo, bool isDone) async {
    try {
      // Update local state
      todo.isDone = isDone;
      // Update Firestore document
      await _taskRepository.updateTodoIsDone(task, todo);
    } catch (e) {
      // Handle other exceptions
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  int getCompletedTodoCount(Tasks tasks) {
    int completedTodoCount = 0;
    for (var todo in tasks.todos) {
      if (todo.isDone) {
        completedTodoCount++;
      }
    }
    return completedTodoCount;
  }

  Future<void> updateKarma(Tasks tasks) async {
    try {
      // Increment karma when task is marked as completed
      if (tasks.todos.every((todo) => todo.isDone)) {
        tasks = tasks.copyWith(karma: tasks.karma + 1);
      }
      await _taskRepository.updateKarma(tasks);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteTask(Tasks task) async {
    final result = await _taskRepository.deleteTask(task);

    result.fold(
      (failure) => Fluttertoast.showToast(msg: failure.message),
      (_) => Fluttertoast.showToast(msg: 'Task Deleted Successfully'),
    );
  }

  Future<void> deleteSubtaskById(String taskId, String subtaskId) async {
    final result = await _taskRepository.deleteSubtaskById(taskId, subtaskId);

    result.fold(
      (failure) => Fluttertoast.showToast(msg: failure.message),
      (_) => Fluttertoast.showToast(msg: 'Sub Task Deleted Successfully'),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}
