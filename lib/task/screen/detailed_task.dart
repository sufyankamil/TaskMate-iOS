import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:task_mate/common/constants.dart';
import 'package:task_mate/core/utils/extensions.dart';
import 'package:task_mate/task/screen/ongoing_task.dart';

import '../../../model/task_model.dart';
import '../../../theme/pallete.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/task_controller.dart';

class DetailedPage extends ConsumerStatefulWidget {
  final String taskId;

  const DetailedPage({super.key, required this.taskId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DetailedPageState();
}

class _DetailedPageState extends ConsumerState<DetailedPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);

    final GlobalKey<FormState> formKeys = GlobalKey<FormState>();

    List<String> tasks = [];

    final subTaskIds = ref
        .watch(taskControllerProvider.notifier)
        .fetchSubTaskIds(widget.taskId);

    int taskCompleted(Tasks task) {
      int doneTodo = 0;
      for (var todo in task.todos) {
        // Check `if the current element is a Todo object with an isDone property
        if (todo.isDone) {
          doneTodo++;
        }
      }
      return doneTodo;
    }

    Color stringToColor(String colorString) {
      final buffer = StringBuffer();
      buffer.write(colorString.replaceAll('#', ''));
      if (buffer.length == 6 || buffer.length == 8) {
        buffer.write('FF'); // Add alpha channel if it's missing
      }
      return Color(int.parse(buffer.toString(), radix: 16));
    }

    bool isTodosEmpty(Tasks tasks) {
      if (tasks.todos.isEmpty) {
        return true;
      } else {
        return false;
      }
    }

    int getDoneTodo(Tasks task) {
      int doneTodo = 0;
      for (var todo in task.todos) {
        if (todo.isDone) {
          doneTodo++;
        }
      }
      return doneTodo;
    }

    final usersTask = ref.watch(userTaskProvider);

    final usersData = usersTask.when(
      data: (data) => data,
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (e, s) => const Center(
        child: Text('Error'),
      ),
    );

    final usersNewData = usersTask.when(
      data: (data) => data,
      loading: () =>
          null, // Return null for loading state or handle it as needed
      error: (e, s) =>
          null, // Return null for error state or handle it as needed
    );

    if (usersNewData != null) {
      // Fetch the dates when task was created
      for (var task in usersNewData) {
        tasks.add(DateFormat('dd-MM-yyyy').format(task.createdAt));
      }

      // print('tasks: $tasks');

      // Sort the dates in descending order
      tasks.sort((a, b) => b.compareTo(a));
    } else {
      // Handle loading or error state here if necessary
      if (kDebugMode) {
        print('Loading or Error State');
      }
    }

    // Check if usersData is empty
    final bool isUserDataEmpty = usersData is Iterable && usersData.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.taskDetail),
        actions: [
          IconButton(
            onPressed: () {
              // final userDataList = usersData.toList();

              if (kDebugMode) {
                print("userDataList: ");
              }
            },
            icon: const Tooltip(
              waitDuration: Duration(seconds: 100),
              message: 'Swipe on the task to see list of options',
              child: Icon(Icons.help_outline),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              color: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 4,
              child: const SizedBox(
                width: double.infinity,
                height: 200,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                ref.watch(taskByIdProvider(widget.taskId)).when(
                      data: (data) => Form(
                        key: formKeys,
                        child: SizedBox(
                          height: 77.0.widthPercent,
                          width: double.infinity,
                          child: ListView(
                            children: [
                              SizedBox(height: 3.0.widthPercent),
                              taskTitle(stringToColor, data),
                              const SizedBox(height: 6.0),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  data.subTitle,
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    fontSize: 12.0.textPercentage,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              taskdescription(stringToColor, data),
                              const SizedBox(height: 16.0),
                              Padding(
                                padding: const EdgeInsets.only(left: 9.0),
                                child: Row(
                                  children: [
                                    taskDue(stringToColor, data),
                                    SizedBox(width: 30.0.widthPercent),
                                    peopleInvolved(stringToColor, data),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  stepper(data, isTodosEmpty, getDoneTodo,
                                      stringToColor, currentTheme),
                                  SizedBox(width: 10.0.widthPercent),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        bottom: 10,
                                        right: 10),
                                    child: Text(
                                      '${data.todos.isEmpty ? '0' : ((taskCompleted(data) / data.todos.length) * 100).toStringAsFixed(0)}% ',
                                      style: TextStyle(
                                        overflow: TextOverflow.clip,
                                        fontSize: 12.0.textPercentage,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              project(stringToColor),
                            ],
                          ),
                        ),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      error: (error, stackTrace) => Center(
                        child: Text(error.toString()),
                      ),
                    ),
                choices(stringToColor),
                StreamBuilder<List<String>>(
                  stream: subTaskIds,
                  builder: (context, snapshot) {
                    final subTaskIds = snapshot.data;

                    if (snapshot.connectionState == ConnectionState.active) {
                      return OnGoingTask(
                        taskId: widget.taskId,
                        selectedChoiceIndex: selectedIndex,
                        subTaskIds: subTaskIds!,
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return OnGoingTask(
                        taskId: widget.taskId,
                        selectedChoiceIndex: selectedIndex,
                        subTaskIds: subTaskIds ?? [],
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: isUserDataEmpty
          ? FloatingActionButton(
              onPressed: () {
                final userDataList = usersData.toList();

                if (kDebugMode) {
                  print("userDataList: $userDataList");
                }

                if (userDataList.isNotEmpty) {
                  addSubTask(context, ref);
                }
              },
              child: const Icon(Icons.add),
            )
          : const SizedBox(),
    );
  }

  void addSubTask(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    TextEditingController titleController = TextEditingController();

    TextEditingController descriptionController = TextEditingController();

    String? titleErrorText;

    String? descriptionErrorText;

    String title = '';

    final taskDetails = ref.watch(taskByIdProvider(widget.taskId));

    // Check the status of the AsyncData
    if (taskDetails is AsyncData<Tasks>) {
      // Access the value inside AsyncData
      Tasks tasks = taskDetails.value;

      // Access specific properties of the Tasks object
      title = tasks.title;
    }

    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          return CupertinoPopupSurface(
            child: Material(
              child: Form(
                key: formKey,
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: 200.0.widthPercent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Routemaster.of(context).pop();
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Add Sub Task to project: $title',
                        style: TextStyle(
                          fontFamily: 'MyFont',
                          fontSize: 6.3.widthPercent,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'Sub Task Title',
                            hintStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            errorText: titleErrorText,
                            errorStyle: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'Sub Task Description',
                            hintStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            errorText: descriptionErrorText,
                            errorStyle: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Description is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            if (taskDetails is AsyncData<Tasks>) {
                              // Access the value inside AsyncData
                              Tasks tasks = taskDetails.value;

                              // Call the updateTasksWithSubTask function
                              ref
                                  .read(postControllerProvider.notifier)
                                  .updateTasksWithSubTask(
                                    tasks,
                                    titleController.text,
                                    descriptionController.text,
                                  );
                            }
                            titleController.clear();
                            descriptionController.clear();
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          minimumSize: Size(50.0.widthPercent, 40),
                          maximumSize: Size(60.0.widthPercent, 40),
                        ),
                        child: Text(
                          'Add Sub Task',
                          style: TextStyle(
                            fontSize: 10.0.textPercentage,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Padding stepper(
      Tasks data,
      bool Function(Tasks tasks) isTodosEmpty,
      int Function(Tasks task) getDoneTodo,
      Color Function(String colorString) stringToColor,
      ThemeData currentTheme) {
    return Padding(
      padding: EdgeInsets.only(
        top: 3.0.widthPercent,
        left: 3.0.widthPercent,
      ),
      child: SizedBox(
        width: 70.0.widthPercent,
        child: StepProgressIndicator(
          totalSteps: isTodosEmpty(data) ? 1 : data.todos.length,
          currentStep: isTodosEmpty(data) ? 0 : getDoneTodo(data),
          size: 18,
          roundedEdges: const Radius.circular(10),
          padding: 0,
          selectedGradientColor: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              stringToColor(data.color!).withOpacity(0.5),
              stringToColor(data.color!),
            ],
          ),
          unselectedGradientColor: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              currentTheme.primaryColorLight,
              currentTheme.primaryColorLight.withOpacity(0.5),
            ],
          ),
        ),
      ),
    );
  }

  Padding taskTitle(
      Color Function(String colorString) stringToColor, Tasks data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
      child: Text(data.title,
          style: TextStyle(
            overflow: TextOverflow.clip,
            fontSize: 15.0.textPercentage,
            fontWeight: FontWeight.bold,
          ),
          softWrap: true),
    );
  }

  Padding taskdescription(
      Color Function(String colorString) stringToColor, Tasks data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Constants.taskDetailDescription,
            style: TextStyle(
              overflow: TextOverflow.clip,
              fontSize: 12.0.textPercentage,
              color: Colors.white,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 6.0),
          Text(data.description,
              style: TextStyle(
                overflow: TextOverflow.clip,
                fontSize: 12.0.textPercentage,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
              softWrap: true),
        ],
      ),
    );
  }

  Padding taskDue(
      Color Function(String colorString) stringToColor, Tasks data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.0.widthPercent),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Constants.taskDueDate,
                style: TextStyle(
                  overflow: TextOverflow.clip,
                  fontSize: 12.0.textPercentage,
                  color: Colors.white,
                ),
                softWrap: true,
              ),
              const SizedBox(height: 6.0),
              Text(data.date,
                  style: TextStyle(
                    overflow: TextOverflow.clip,
                    fontSize: 12.0.textPercentage,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                  softWrap: true),
            ],
          ),
        ],
      ),
    );
  }

  SingleChildScrollView peopleInvolved(
      Color Function(String colorString) stringToColor, Tasks data) {
    final user = ref.watch(userProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(
            Constants.taskPeopleInvolved,
            style: TextStyle(
              overflow: TextOverflow.clip,
              fontSize: 12.0.textPercentage,
              color: Colors.grey,
            ),
            softWrap: true,
          ),
          IconButton(
            onPressed: () {},
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundImage: NetworkImage(
                    user!.photoUrl,
                  ),
                ),
                Positioned(
                  left: 10,
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 4, minHeight: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: NetworkImage(
                            user.photoUrl,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding project(Color Function(String colorString) stringToColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
      child: Text(Constants.project,
          style: TextStyle(
            overflow: TextOverflow.clip,
            fontSize: 12.0.textPercentage,
            fontWeight: FontWeight.bold,
          ),
          softWrap: true),
    );
  }

  Padding choices(Color Function(String colorString) stringToColor) {
    List<String> choices = ['To-Do', 'In Progress', 'Completed'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Wrap(
            spacing: 25.0,
            children: List<Widget>.generate(choices.length, (int index) {
              return ChoiceChip(
                label: Text(choices[index]),
                selected: selectedIndex == index,
                selectedColor: Colors.blue,
                onSelected: (bool selected) {
                  setState(() {
                    selectedIndex = selected ? index : selectedIndex;
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
