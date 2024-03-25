import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpdart/fpdart.dart';

import 'package:routemaster/routemaster.dart';
import 'package:task_mate/common/constants.dart';
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

final subTaskByIdsProvider =
    StreamProvider.family.autoDispose((ref, String taskId) {
  final taskController = ref.watch(postControllerProvider.notifier);
  return taskController.fetchSubTaskIds(taskId);
});

final fetchSubTaskByIdOnly =
    StreamProvider.family.autoDispose((ref, String subTaskId) {
  final taskController = ref.watch(postControllerProvider.notifier);
  return taskController.fetchSubTaskByIdOnly(subTaskId);
});

// final fetchTodoByIdProvider = StreamProvider.family
//     .autoDispose<Todo, String, String>((ref, taskId, subTaskId) {
//   final taskController = ref.watch(postControllerProvider.notifier);
//   return taskController.fetchSubTaskById(taskId, subTaskId);
// });

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
    String? description,
    String? subTitle,
    String? date,
    String? time,
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
        Fluttertoast.showToast(msg: Constants.taskAlreadyExists);
        return;
      } else {
        final Tasks tasks = Tasks(
          id: taskId,
          title: title,
          description: description ?? '',
          subTitle: subTitle ?? ' ',
          color: colors.value.toRadixString(16).padLeft(8, '0'),
          createdAt: DateTime.now(),
          uid: uid,
          isPending: true,
          isCompleted: false,
          isCollaborative: false,
          date: date ?? '',
          time: time ?? '',
        );

        if (kDebugMode) {
          print(tasks.toMap());
        }

        final result = await _taskRepository.addTask(tasks);

        state = false;

        result.fold(
          (failure) => Fluttertoast.showToast(msg: failure.message),
          (_) {
            Fluttertoast.showToast(msg: Constants.taskAddedSuccessfully);
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

  void addTaskInSession({
    required BuildContext context,
    required String title,
    String? description,
    String? date,
    String? time,
  }) async {
    state = true;

    String taskId = const Uuid().v1();

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
        Fluttertoast.showToast(msg: Constants.taskAlreadyExists);
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
          isCollaborative: true,
          date: date ?? '',
          time: time ?? '',
        );

        if (kDebugMode) {
          print(tasks.toMap());
        }

        final result = await _taskRepository.addTask(tasks);

        state = false;

        result.fold(
          (failure) => Fluttertoast.showToast(msg: failure.message),
          (_) {
            Fluttertoast.showToast(msg: Constants.taskAddedSuccessfully);
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

  Stream<Todo> fetchSubTaskById(String taskId, String subTaskId) {
    return _taskRepository.fetchSubTaskById(taskId, subTaskId);
  }

  Stream<Todo> fetchSubTaskByIdOnly(String subTaskId) {
    try {
      return _taskRepository.fetchSubTaskByIdOnly(subTaskId);
    } catch (e) {
      throw e.toString();
    }
  }

  Stream<List<String>> fetchSubTaskIds(String taskId) {
    try {
      return _taskRepository.fetchSubTaskIds(taskId);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Either<Failure, void>> updateTasksWithSubTask(
    Tasks tasks,
    String subTaskTitle,
    String subTaskDescription,
  ) async {
    try {
      // Create a new Todo object with the provided title
      Todo newSubTask = Todo(
        id: const Uuid().v1(),
        title: subTaskTitle,
        description: subTaskDescription,
        isPending: true,
        inProgress: false,
        isDone: false,
        assignedBy: '',
        assignedTo: '',
        attachments: [],
        comments: '',
      );

      // Add the new subtask to the existing todos list
      tasks = tasks.copyWith(todos: [...tasks.todos, newSubTask]);

      // Update the document in Firestore
      await _taskRepository.updateTasksWithSubTask(tasks, subTaskTitle);

      Fluttertoast.showToast(msg: Constants.subTaskAdded);

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

  Future<void> updateTodoIsPending(
      Tasks task, Todo todo, bool isPending) async {
    try {
      // Update local state
      todo.isPending = isPending;
      todo.inProgress = false;
      todo.isDone = false;
      // Update Firestore document
      await _taskRepository.updateTodoIsDone(task, todo);
    } catch (e) {
      // Handle other exceptions
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> updateTodoInProgress(
      Tasks task, Todo todo, bool inProgress) async {
    try {
      // Update local state
      todo.inProgress = inProgress;
      todo.isPending = false;
      todo.isDone = false;
      // Update Firestore document
      await _taskRepository.updateTodoIsDone(task, todo);
    } catch (e) {
      // Handle other exceptions
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> updateTodoIsDone(Tasks task, Todo todo, bool isDone) async {
    try {
      // Update local state
      todo.isDone = isDone;
      todo.isPending = false;
      todo.inProgress = false;
      // Update Firestore document
      await _taskRepository.updateTodoIsDone(task, todo);
    } catch (e) {
      // Handle other exceptions
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> updateTodoIsCollaborative(
      Tasks task, bool isCollaborative) async {
    try {
      // Update local state
      task.isCollaborative = isCollaborative;
      // Update Firestore document
      await _taskRepository.updateTodoIsCollaborative(task, isCollaborative);
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
      (_) => Fluttertoast.showToast(msg: Constants.taskDeleted),
    );
  }

  Future<void> deleteSubtaskById(String taskId, String subtaskId) async {
    final result = await _taskRepository.deleteSubtaskById(taskId, subtaskId);

    result.fold(
      (failure) => Fluttertoast.showToast(msg: failure.message),
      (_) => Fluttertoast.showToast(msg: Constants.subTaskDeleted),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}
