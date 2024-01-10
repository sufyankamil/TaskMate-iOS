import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:task_mate/core/utils/extensions.dart';
import 'package:task_mate/theme/pallete.dart';

import '../../auth/controller/auth_controller.dart';
import '../../model/session_model.dart';
import '../controller/session_controller.dart';
import '../repository/session_repository.dart';
import 'showing_session_tasks.dart';

class SessionJoined extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionJoined({super.key, required this.sessionId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SessionJoinedState();
}

class _SessionJoinedState extends ConsumerState<SessionJoined> {
  TextEditingController sessionIdController = TextEditingController();

  void navigateToSessionCreation() {
    Routemaster.of(context).push('/');
  }

  List<String> usersList = [];

  String? ownerId = '';

  Future<void> fetchOwnerId() async {
    final sessionController = ref.watch(sessionControllerProvider.notifier);

    ownerId = await sessionController.getOwnerId(widget.sessionId);
  }

  final ownerIdProvider = FutureProvider<String?>((ref) async {
    final sessionRepository = ref.read(sessionRepositoryProvider);
    final sessionId = ref.read(sessionIdProvider);

    // Perform the asynchronous operation
    try {
      final ownerId = await sessionRepository.getOwnerId(sessionId!);
      return ownerId;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting owner ID: $e');
      }
      // Optionally, you can rethrow the error or return a default value.
      return null;
    }
  });

  // Function to fetch session details
  Future<void> fetchSessionDetails() async {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final sessionController = ref.watch(sessionControllerProvider.notifier);
      Session? sessionDetails =
          await sessionController.getSessionDetails(widget.sessionId);

      if (sessionDetails != null) {
        ownerId = sessionDetails.ownerId;
      }
    });
  }

  void showSuccessMessage() {
    Fluttertoast.showToast(
      msg: 'Session joined successfully',
      backgroundColor: Colors.green,
      timeInSecForIosWeb: 4,
    );
  }

  fetchSessionWithTask() {
    final sessionController = ref.watch(sessionControllerProvider.notifier);
    return sessionController.fetchSessionWithTask();
  }

  @override
  void initState() {
    super.initState();
    fetchSessionDetails();
    showSuccessMessage();
    fetchSessionWithTask();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);

    final sessionController = ref.watch(sessionControllerProvider.notifier);

    final Stream<List<String>> sessions =
        sessionController.fetchUsersInSession(widget.sessionId);

    final userId = ref.read(userProvider)?.uid ?? '';

    final isOwner = ownerId == userId;

    final squreWidth = MediaQuery.of(context).size.width - 10.0.widthPercent;

    final themeNotifier = ref.watch(themeNotifierProvider.notifier);

    bool isDarkTheme = themeNotifier.isDark;

    final sessionControl = ref.watch(sessionControllerProvider.notifier);

    GlobalKey<RefreshIndicatorState> refreshKey =
        GlobalKey<RefreshIndicatorState>();

    final usersSessionTask = ref.watch(userSessionTask);

    final sessionTodos = usersSessionTask.when(
      data: (data) {
        print('Data: $data');
        return data;
            },
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (error, stack) {
        print('Error: $error');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text('Error: $error'),
            ),
          ],
        );
      },
    );

    print('Outside usersSessionTask: $sessionTodos');


    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Session Started"),
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.plus),
            onPressed: () {
              addSessionTask(context, ref);
            },
          )),
      endDrawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Session ID',
                        style: TextStyle(
                            color: Colors.white, fontSize: 5.0.widthPercent),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          endSessionMethod(context);
                        },
                        child: isOwner
                            ? const Text(
                                'End Session',
                                style: TextStyle(color: Colors.red),
                              )
                            : const Text(
                                'Leave Session',
                                style: TextStyle(color: Colors.red),
                              ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text(
                      widget.sessionId,
                      style: TextStyle(
                          color: Colors.white, fontSize: 3.0.widthPercent),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: widget.sessionId));
                        Fluttertoast.showToast(
                          msg: 'Session ID copied to clipboard',
                          backgroundColor: Colors.green,
                        );
                      },
                    ),
                  ),
                  countNumberOfUsers(sessions)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Users in Session',
                style:
                    TextStyle(color: Colors.white, fontSize: 5.0.widthPercent),
              ),
            ),
            StreamBuilder<List<String>>(
              stream: sessions,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return const Text('Error');
                } else {
                  final List<String> users = snapshot.data ?? [];
                  final int userCount = users.length;
                  Future.delayed(Duration.zero, () {
                    setState(() {
                      usersList = snapshot.data ?? [];
                    });
                  });

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (userCount > 0)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: userCount,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    radius: 20,
                                    child: Text('${index + 1}'),
                                  ),
                                ),
                                SizedBox(width: 8.0.widthPercent),
                                Text(users[index]),
                              ],
                            );
                          },
                        ),
                      if (userCount == 0) const Text('No users in session'),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refreshKey.currentState?.show();
          // return Future.delayed(const Duration(seconds: 2));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             sessionTodos is List && sessionTodos.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'No task found in this Session, Start adding task so that you don\'t forget your important task',
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
                  )
                :
            ref.watch(userSessionTask).when(
                  data: (data) => Expanded(
                    child: SingleChildScrollView(
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        children: [
                          ...data.map(
                            (session) => LongPressDraggable(
                              data: session.tasks.isNotEmpty ? session.tasks[0] : null,
                              feedback: Opacity(
                                opacity: 0.8,
                                child: ShowSessionTasks(sessionTodo: session.tasks.isNotEmpty ? session.tasks[0] : null),
                              ),
                              child: ShowSessionTasks(sessionTodo: session.tasks.isNotEmpty ? session.tasks[0] : null),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                  error: (error, stack) => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text('Error: $error'),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<List<String>> countNumberOfUsers(
      Stream<List<String>> sessions) {
    return StreamBuilder<List<String>>(
      stream: sessions,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Fluttertoast.showToast(
            msg: 'Error getting users in session',
            backgroundColor: Colors.red,
          );
          return const Text('Error');
        } else {
          final List<String> users = snapshot.data ?? [];
          final int userCount = users.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Total Users Joined: $userCount'),
            ],
          );
        }
      },
    );
  }

  Future<dynamic> endSessionMethod(
    BuildContext context,
  ) async {
    final sessionController = ref.watch(sessionControllerProvider.notifier);

    // ownerId = await sessionController.getOwnerId(widget.sessionId);

    // final userId = ref.read(userProvider)?.uid ?? '';

    // final isOwner = ownerId == userId;

    // ignore: use_build_context_synchronously
    return showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: const Text('Leave Session'),
        content: const Text('Are you sure you want to leave the session?'),
        actions: [
          BasicDialogAction(
            title: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          BasicDialogAction(
            title: const Text('Leave Session'),
            onPressed: () {
              sessionController.endSession();
              Navigator.pop(context);
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Session left successfully',
                backgroundColor: Colors.green,
              );
              navigateToSessionCreation();
            },
          ),
        ],
      ),
    );
  }

  Future<dynamic> leaveSessionMethod(
      BuildContext context, int userIndex) async {
    final sessionController = ref.watch(sessionControllerProvider.notifier);

    ownerId = await sessionController.getOwnerId(widget.sessionId);

    final userId = ref.read(userProvider)?.uid ?? '';

    final isOwner = ownerId == userId;

    void leaveSessionForCurrentUser(int userIndex) async {
      final sessionController = ref.watch(sessionControllerProvider.notifier);
      final String? currentUserUid = ref.read(userProvider)?.uid;

      if (currentUserUid != null) {
        await sessionController.leaveSession(widget.sessionId, currentUserUid);
        Navigator.pop(context);
        Navigator.pop(context);
        navigateToSessionCreation();
      } else {
        // Handle the case where the current user's UID is null
        print("Current user UID is null");
      }
    }

    // Check if the user is the owner
    if (isOwner) {
      // Perform actions for the owner (e.g., end session)
      sessionController.endSession();
      Navigator.pop(context);
      Navigator.pop(context);
      navigateToSessionCreation();
    } else {
      // Perform actions for non-owner (e.g., leave session)
      leaveSessionForCurrentUser(userIndex);
    }
  }

  void addSessionTask(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    TextEditingController titleController = TextEditingController();

    TextEditingController descriptionController = TextEditingController();

    String? _errorText1 = "Please enter a task title";

    String? _errorText2 = "Please enter a task Description";

    String? formattedDate = '';

    DateTime selectedDate = DateTime.now();

    TimeOfDay selectedTime = TimeOfDay.now();

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null && pickedDate != selectedDate) {
        setState(() {
          selectedDate = pickedDate;
          formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
        });
      }
    }

    // Convert TimeOfDay to DateTime for formatting
    DateTime dateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      selectedTime.hour,
      selectedTime.minute,
    );

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );

      if (pickedTime != null && pickedTime != selectedTime) {
        setState(() {
          selectedTime = pickedTime;
          DateFormat('h:mm a').format(dateTime);
        });
      }
    }

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return CupertinoPopupSurface(
          child: Form(
            key: _formKey,
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
                            Navigator.pop(context);
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
                    'Add Task to Session',
                    style: TextStyle(
                      fontFamily: 'MyFont',
                      fontSize: 7.0.widthPercent,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  titleWidget(titleController, _errorText1),
                  const SizedBox(height: 20),
                  CupertinoTextFormFieldRow(
                    style: const TextStyle(color: Colors.white),
                    prefix: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.description, color: Colors.white),
                    ),
                    controller: descriptionController,
                    placeholder: 'Task Description',
                    keyboardType: TextInputType.multiline,
                    padding: const EdgeInsets.all(12.0),
                    placeholderStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task description';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _errorText2 = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextFormFieldRow(
                          style: const TextStyle(color: Colors.white),
                          prefix: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                                onTap: () => _selectDate(context),
                                child: const Icon(Icons.date_range,
                                    color: Colors.white)),
                          ),
                          controller: TextEditingController(
                            text: "$formattedDate",
                          ),
                          placeholder: 'Select date',
                          padding: const EdgeInsets.all(12.0),
                          placeholderStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a valid date';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _errorText2 = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  timerWidget(_selectTime, context, selectedTime, _errorText2),
                  const SizedBox(height: 20),
                  submitButton(
                      _formKey,
                      ref,
                      titleController,
                      descriptionController,
                      formattedDate,
                      selectedTime,
                      context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  CupertinoTextFormFieldRow titleWidget(
      TextEditingController titleController, String? _errorText1) {
    return CupertinoTextFormFieldRow(
      style: const TextStyle(color: Colors.white),
      prefix: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.title, color: Colors.white),
      ),
      controller: titleController,
      placeholder: 'Task Title',
      padding: const EdgeInsets.all(12.0),
      placeholderStyle: const TextStyle(
        color: Colors.grey,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a task title';
        }
        return null;
      },
      onChanged: (value) {
        titleController.text = value;
        setState(() {
          _errorText1 = null;
        });
      },
    );
  }

  CupertinoButton submitButton(
      GlobalKey<FormState> _formKey,
      WidgetRef ref,
      TextEditingController titleController,
      TextEditingController descriptionController,
      String? formattedDate,
      TimeOfDay selectedTime,
      BuildContext context) {
    return CupertinoButton.filled(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          final sessionController =
              ref.watch(sessionControllerProvider.notifier);

          Session? sessionDetails =
              await sessionController.getSessionDetails(widget.sessionId);

          final result = sessionController.updateSessionTask(
            sessionDetails!,
            titleController.text.trim(),
            descriptionController.text.trim(),
            formattedDate!,
            selectedTime.format(context),
            'Pending',
            widget.sessionId,
          );

          titleController.clear();
          descriptionController.clear();

          Navigator.pop(context);
        }
      },
      child: const Text('Submit'),
    );
  }

  Row timerWidget(Future<void> Function(BuildContext context) _selectTime,
      BuildContext context, TimeOfDay selectedTime, String? _errorText2) {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextFormFieldRow(
            prefix: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                    onTap: () => _selectTime(context),
                    child: const Icon(Icons.timer, color: Colors.white))),
            style: const TextStyle(color: Colors.white),
            controller: TextEditingController(
              text: selectedTime.format(context),
            ),
            placeholder: 'Select time',
            padding: const EdgeInsets.all(12.0),
            placeholderStyle: const TextStyle(
              color: Colors.grey,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select time';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _errorText2 = null;
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    sessionIdController.dispose();
  }
}
