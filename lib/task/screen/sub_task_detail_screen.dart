import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_mate/core/utils/extensions.dart';
import 'package:task_mate/model/todo.dart';

import '../../common/constants.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/task_model.dart';
import '../controller/task_controller.dart';

class SubTaskDetail extends ConsumerStatefulWidget {
  final String taskId;

  final List<String> subTaskId;

  final int selectedSubChoiceIndex;

  const SubTaskDetail(
      {super.key,
      required this.taskId,
      required this.subTaskId,
      required this.selectedSubChoiceIndex});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SubTaskDetailState();
}

class _SubTaskDetailState extends ConsumerState<SubTaskDetail> {
  bool inProgress = false;

  bool inPending = false;

  bool isDone = false;

  TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subTask = ref.watch(
        fetchSubTaskByIdOnly(widget.subTaskId[widget.selectedSubChoiceIndex]));

    String dueDate = '';

    final taskDetails = ref.watch(taskByIdProvider(widget.taskId));

    if (taskDetails is AsyncData<Tasks>) {
      Tasks tasks = taskDetails.value;

      dueDate = tasks.date;
    }

    String subTaskTitle = '';

    String subTaskDescription = '';

    subTask.when(
      data: (subTaskValue) {
        Todo subTasks = subTaskValue;

        subTaskTitle = subTasks.title;

        subTaskDescription = subTasks.description;

        inProgress = subTasks.inProgress;

        inPending = subTasks.isPending;

        isDone = subTasks.isDone;
      },
      loading: () {
        const CircularProgressIndicator.adaptive();
      },
      error: (error, stackTrace) {
        Fluttertoast.showToast(
          msg: 'Error while fetching sub task',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        if (kDebugMode) {
          print('Error while fetching sub task: $error');
        }
      },
    );

    Color stringToColor(String colorString) {
      final buffer = StringBuffer();
      buffer.write(colorString.replaceAll('#', ''));
      if (buffer.length == 6 || buffer.length == 8) {
        buffer.write('FF'); // Add alpha channel if it's missing
      }
      return Color(int.parse(buffer.toString(), radix: 16));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.subTaskDetail),
        actions: [
          IconButton(
            onPressed: () {},
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.0.widthPercent),
            subTaskTitleForm(stringToColor, subTaskTitle),
            SizedBox(height: 5.0.widthPercent),
            subTaskdescription(stringToColor, subTaskDescription),
            SizedBox(height: 5.0.widthPercent),
            statusSubtask(stringToColor, subTaskDescription),
            SizedBox(height: 3.0.widthPercent),
            subTaskDue(stringToColor, dueDate),
            SizedBox(height: 3.0.widthPercent),
            attachments(stringToColor, dueDate),
            SizedBox(height: 3.0.widthPercent),
            addAttachments(stringToColor, dueDate),
            SizedBox(height: 4.0.widthPercent),
            comments(stringToColor, dueDate, commentController),
            SizedBox(height: 4.0.widthPercent),
            commentButton(stringToColor, Constants.cancel, Constants.send),
          ],
        ),
      ),
    );
  }

  Padding subTaskTitleForm(
      Color Function(String colorString) stringToColor, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
      child: Text(title,
          style: TextStyle(
            overflow: TextOverflow.clip,
            fontSize: 17.0.textPercentage,
            fontWeight: FontWeight.bold,
          ),
          softWrap: true),
    );
  }

  Padding subTaskdescription(
      Color Function(String colorString) stringToColor, String description) {
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
          const SizedBox(height: 2.0),
          Text(description,
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

  Padding statusSubtask(
      Color Function(String colorString) stringToColor, String status) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Constants.subTaskStatus,
            style: TextStyle(
              overflow: TextOverflow.clip,
              fontSize: 12.0.textPercentage,
              color: Colors.white,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 2.0),
          DropdownMenuItem(
            value: inProgress
                ? 'In Progress'
                : (inPending ? 'Not Started' : 'Done'),
            child: Text(
              inProgress ? 'In Progress' : (inPending ? 'Not Started' : 'Done'),
              style: TextStyle(
                overflow: TextOverflow.clip,
                fontSize: 12.0.textPercentage,
                color: isDone
                    ? Colors.green
                    : (inPending ? Colors.red : Colors.yellowAccent),
                fontWeight: FontWeight.normal,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Padding subTaskDue(
      Color Function(String colorString) stringToColor, String date) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
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
              const SizedBox(height: 2.0),
              Text(date,
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

  Padding attachments(
      Color Function(String colorString) stringToColor, String date) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Constants.attachments,
            style: TextStyle(
              overflow: TextOverflow.clip,
              fontSize: 12.0.textPercentage,
              color: Colors.white,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }

  Padding addAttachments(
      Color Function(String colorString) stringToColor, String date) {
    double centerWidth =
        (MediaQueryData.fromView(WidgetsBinding.instance.window).size.width -
                20.0.widthPercent) /
            2;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 25.0.widthPercent),
            child: Container(
              width: centerWidth,
              height: centerWidth,
              margin: const EdgeInsets.all(4.0),
              child: InkWell(
                onTap: () async {
                  showAttachmentOptions(context);
                },
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(10.0),
                  color: Colors.grey,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.grey,
                          size: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAttachmentOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Add Attachment'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context); // Close the action sheet
                final image =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                // Handle the selected image
              },
              child: const Text('Add Image'),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context); // Close the action sheet
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                // Handle the selected PDF file
              },
              child: const Text('Add PDF'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context); // Close the action sheet
            },
            child: const Text('Cancel'),
            isDefaultAction: true,
          ),
        );
      },
    );
  }

  Padding comments(
    Color Function(String colorString) stringToColor,
    String comment,
    commentController,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Constants.comments,
            style: TextStyle(
              overflow: TextOverflow.clip,
              fontSize: 13.0.textPercentage,
              color: Colors.white,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 3.0),
          TextFormField(
            autofocus: false,
            controller: commentController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: Constants.addComment,
              hintStyle: const TextStyle(
                color: Colors.grey,
              ),
            ),
            style: const TextStyle(
              color: Colors.white,
            ),
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            onChanged: (value) {
              // You can add an onChanged callback if needed
            },
          ),
        ],
      ),
    );
  }

  Padding commentButton(Color Function(String colorString) stringToColor,
      String cancelButton, String sendButton) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.widthPercent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              commentController.clear();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
            ),
            child: Text(cancelButton),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
           
            child: Text(
              sendButton,
            ),
          ),
        ],
      ),
    );
  }
}
