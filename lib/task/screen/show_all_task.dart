import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:task_mate/auth/controller/auth_controller.dart';
import 'package:task_mate/common/constants.dart';
import 'package:task_mate/core/utils/extensions.dart';
import 'package:task_mate/theme/pallete.dart';

import '../../model/task_model.dart';
import '../controller/task_controller.dart';

class ShowAllTask extends ConsumerStatefulWidget {
  const ShowAllTask({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShowAllTaskState();
}

class _ShowAllTaskState extends ConsumerState<ShowAllTask> {
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  void navigateToTaskDetail(BuildContext context, String taskId) {
    Routemaster.of(context).push('/task-detail/$taskId');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    final currentTheme = ref.watch(themeNotifierProvider);

    final usersTask = ref.watch(userTaskProvider);

    Padding stepper(
        Tasks data,
        bool Function(Tasks tasks) isTodosEmpty,
        int Function(Tasks task) getDoneTodo,
        Color Function(String colorString) stringToColor,
        ThemeData currentTheme) {
      return Padding(
        padding: EdgeInsets.only(
          top: 5.0.widthPercent,
          left: 3.0.widthPercent,
        ),
        child: Row(
          children: [
            StepProgressIndicator(
              totalSteps: isTodosEmpty(data) ? 1 : data.todos.length,
              currentStep: isTodosEmpty(data) ? 0 : getDoneTodo(data),
              size: 10,
              roundedEdges: const Radius.circular(10),
              padding: 0,
              selectedGradientColor: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.withOpacity(0.5),
                  Colors.deepPurpleAccent,
                ],
              ),
              unselectedGradientColor: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.5),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Color stringToColor(String colorString) {
      final buffer = StringBuffer();
      buffer.write(colorString.replaceAll('#', ''));
      if (buffer.length == 6 || buffer.length == 8) {
        buffer.write('FF'); // Add alpha channel if it's missing
      }
      return Color(int.parse(buffer.toString(), radix: 16));
    }

    var totalTodos = 0;

    var inCompleteTaskLength = 0;

    int totalCountOfTodos(List<Tasks> tasks) {
      int count = 0;

      for (var task in tasks) {
        count += task.todos.length;
      }

      totalTodos = count;

      return count;
    }

    final userTasks = ref.watch(userTaskProvider);

    int countIncompleteTodos(List<Tasks> tasks) {
      int count = 0;

      for (var task in tasks) {
        for (var todo in task.todos) {
          if (!todo.isDone) {
            count++;
          }
        }
      }

      return count;
    }

    var completedTaskLength = 0;

    userTasks.when(
      data: (value) {
        // Count total todos
        totalTodos = totalCountOfTodos(value);

        inCompleteTaskLength = countIncompleteTodos(value);

        // Reset the completed task count before counting
        completedTaskLength = 0;

        // Count completed tasks
        for (var task in value) {
          for (var todo in task.todos) {
            if (todo.isDone) {
              completedTaskLength++;
            }
          }
        }
      },
      loading: () {
        const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
      error: (e, s) {},
    );

    double completionPercentage =
        totalTodos == 0 ? 0 : completedTaskLength / totalTodos * 100;

    final usersData = usersTask.when(
      data: (data) {
        final filteredTasks =
            data.where((task) => task.isCollaborative == false).toList();

        if (filteredTasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Text(
                Constants.noTaskFound,
                style: TextStyle(
                  color: currentTheme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          );
        } else {
          return Column(
            children: [
              searchWidget(searchController: searchController),
              const SizedBox(height: 10),
              myTaskRow(title: 'My Task', currentTheme: currentTheme),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 250,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    pauseAutoPlayInFiniteScroll: true,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  items: filteredTasks.map((task) {
                    return Builder(
                      builder: (BuildContext context) {
                        final completedTaskLength =
                            task.todos.where((todo) => todo.isDone).length;
                        final completionPercentage = task.todos.isEmpty
                            ? 0
                            : completedTaskLength / task.todos.length * 100;
                        return GestureDetector(
                          onTap: () {
                            navigateToTaskDetail(context, task.id);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: currentTheme.brightness == Brightness.dark
                                  ? Colors.grey[900]
                                  : Colors.black,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 100,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: currentTheme.brightness ==
                                            Brightness.dark
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                  child: Image.network(
                                    user!.banner,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, left: 10),
                                  child: Text(
                                    task.title,
                                    style: TextStyle(
                                      color: currentTheme.brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 1, left: 10),
                                  child: Text(
                                    task.subTitle,
                                    style: TextStyle(
                                      color: currentTheme.brightness ==
                                              Brightness.dark
                                          ? Colors.grey[300]
                                          : Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    stepper(
                                      task,
                                      (task) => task.todos.isEmpty,
                                      (task) => task.todos
                                          .where((todo) => todo.isDone == true)
                                          .length,
                                      stringToColor,
                                      currentTheme,
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10,
                                          left: 10,
                                          bottom: 10,
                                          right: 10),
                                      child: Text(
                                        '${completionPercentage.toStringAsFixed(0)}% Completed',
                                        style: TextStyle(
                                          color: currentTheme.brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[300]
                                              : Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                          user.photoUrl,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              myTaskRow(title: 'Today\'s Schedule', currentTheme: currentTheme),
            ],
          );
        }
      },
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (e, s) => Center(
        child: ListTile(
          leading: const Icon(Icons.error_outline),
          title: const Text('Error loading tasks'),
          subtitle: Text('$e'),
          trailing: ElevatedButton(
            child: const Text('Retry'),
            onPressed: () {},
          ),
        ),
      ),
    );

    return MaterialApp(
      theme: currentTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            user == null
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : usersData,
          ],
        ),
      ),
    );
  }
}

class myTaskRow extends StatelessWidget {
  const myTaskRow({
    super.key,
    required this.title,
    required this.currentTheme,
  });

  final ThemeData currentTheme;

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, top: 5),
          child: Text(
            title,
            style: TextStyle(
              color: currentTheme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Text(
              'View all',
              style: TextStyle(
                color: currentTheme.brightness == Brightness.dark
                    ? Colors.blue
                    : Colors.black,
                fontSize: 16,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class searchWidget extends StatelessWidget {
  const searchWidget({
    super.key,
    required this.searchController,
  });

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: TextField(
        controller: searchController,
        autofocus: false,
        onChanged: (value) {},
        decoration: const InputDecoration(
          labelText: 'Search',
          hintText: 'Search',
          prefixIcon: Icon(Icons.search),
          suffix: Icon(Icons.filter_alt_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
        ),
      ),
    );
  }
}
