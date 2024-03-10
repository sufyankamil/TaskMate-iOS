import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_mate/auth/controller/auth_controller.dart';
import 'package:task_mate/common/constants.dart';
import 'package:task_mate/theme/pallete.dart';

import '../controller/task_controller.dart';
import 'show_tasks.dart';

class ShowAllTask extends ConsumerStatefulWidget {
  const ShowAllTask({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShowAllTaskState();
}

class _ShowAllTaskState extends ConsumerState<ShowAllTask> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    final usersTask = ref.watch(userTaskProvider);

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
          return Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = filteredTasks[index];
                        return ShowTasks(tasks: task);
                      },
                      childCount: filteredTasks.length,
                    ),
                  ),
                ),
              ],
            ),
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
