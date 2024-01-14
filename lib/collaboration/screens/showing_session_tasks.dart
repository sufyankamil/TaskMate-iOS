import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_mate/core/utils/extensions.dart';

import '../../model/task_model.dart';
import '../../theme/pallete.dart';

class ShowSessionTasks extends ConsumerWidget {
  final Tasks sessionTodo;

  const ShowSessionTasks({super.key, required this.sessionTodo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);

    final squreWidth = MediaQuery.of(context).size.width - 10.0.widthPercent;

    final themeNotifier = ref.watch(themeNotifierProvider.notifier);

    bool isDarkTheme = themeNotifier.isDark;

    return Scaffold(
      body: GestureDetector(
        onTap: () {},
        child: Container(
          width: squreWidth,
          height: squreWidth / 2,
          margin: EdgeInsets.all(4.0.widthPercent),
          decoration: BoxDecoration(
            color: isDarkTheme ? currentTheme.primaryColorDark : Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: isDarkTheme ? Colors.grey[900]! : Colors.grey[300]!,
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 7),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
                  child: Text(
                    sessionTodo.title,
                    style: TextStyle(
                      fontSize: 16.4,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme
                          ? Colors.white
                          : currentTheme.primaryColorDark,
                      decoration: TextDecoration.none,
                    ),
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 7),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
                  child: Text(
                    sessionTodo.karma.toString(),
                    style: TextStyle(
                      fontSize: 14.4,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme
                          ? Colors.white
                          : currentTheme.primaryColorDark,
                      decoration: TextDecoration.none,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
