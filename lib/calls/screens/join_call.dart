import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_mate/calls/screens/conference.dart';

class JoinCall extends StatefulWidget {
  const JoinCall({super.key});

  @override
  State<JoinCall> createState() => _JoinCallState();
}

class _JoinCallState extends State<JoinCall>
    with SingleTickerProviderStateMixin {
  late TextEditingController nameController = TextEditingController();

  late TextEditingController userIdController = TextEditingController();

  late TextEditingController conferenceIdController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();

  final GlobalKey<FormState> _joinFormKey = GlobalKey<FormState>();

  late TabController _tabController;

  String? userID;

  String? name;

  String? conferenceID;

  String generateRandomConferenceID() {
    Random random = Random();
    String conferenceID = '';
    for (int i = 0; i < 6; i++) {
      conferenceID += random.nextInt(10).toString();
    }
    return conferenceID;
  }

  String randomConferenceID = '';

  navigateToConference() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoConferencePage(
          conferenceID: conferenceID ?? randomConferenceID,
          userID: userID!,
          userName: name!,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    randomConferenceID = generateRandomConferenceID();
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameController.dispose();
    userIdController.dispose();
    conferenceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Call and never forget a thing'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Create Session'),
            Tab(text: 'Join Session'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateSessionTab(),
          _buildJoinSessionTab(),
        ],
      ),
    );
  }

  Widget _buildCreateSessionTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _createFormKey,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Create Session',
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              name = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name must not be empty';
              }
              if (value.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
                return 'Name must not contain special characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'User ID',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              userID = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'User ID must not be empty';
              }
              if (value.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
                return 'User ID must not contain special characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_createFormKey.currentState!.validate()) {
                nameController.clear();
                userIdController.clear();
                navigateToConference();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.video_call),
                  SizedBox(width: 8),
                  Text('Connect'),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildJoinSessionTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _joinFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Join Session',
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name must not be empty';
                  }
                  if (value.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
                    return 'Name must not contain special characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  userID = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'User ID must not be empty';
                  }
                  if (value.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
                    return 'User ID must not contain special characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: conferenceIdController,
                decoration: const InputDecoration(
                  labelText: 'Conference ID',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  conferenceID = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Conference ID must not be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_joinFormKey.currentState!.validate()) {
                     nameController.clear();
                    userIdController.clear();
                    conferenceIdController.clear();
                    navigateToConference();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.video_call),
                      SizedBox(width: 8),
                      Text('Join'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  //   return Scaffold(
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text(
  //               'Join Call',
  //               style: Theme.of(context).textTheme.headline5,
  //             ),
  //             const SizedBox(height: 20),
  //             TextFormField(
  //               decoration: const InputDecoration(
  //                 labelText: 'Name',
  //                 border: OutlineInputBorder(),
  //               ),
  //               onChanged: (value) {
  //                 name = value;
  //               },
  //               validator: (value) {
  //                 if (value == null || value.isEmpty) {
  //                   return 'Name must not be empty';
  //                 }
  //                 if (value.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
  //                   return 'Name must not contain special characters';
  //                 }
  //                 return null;
  //               },
  //             ),
  //             const SizedBox(height: 20),
  //             TextFormField(
  //               decoration: const InputDecoration(
  //                 labelText: 'User ID',
  //                 border: OutlineInputBorder(),
  //               ),
  //               onChanged: (value) {
  //                 userID = value;
  //               },
  //               validator: (value) {
  //                 if (value == null || value.isEmpty) {
  //                   return 'User ID must not be empty';
  //                 }
  //                 if (value.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
  //                   return 'User ID must not contain special characters';
  //                 }
  //                 return null;
  //               },
  //             ),
  //             const SizedBox(height: 20),
  //             ElevatedButton(
  //               onPressed: () {
  //                 if (_formKey.currentState!.validate()) {
  //                   navigateToConference();
  //                 }
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.blue,
  //                 elevation: 3,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //               child: const Padding(
  //                 padding: EdgeInsets.symmetric(vertical: 12.0),
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Icon(Icons.video_call),
  //                     SizedBox(width: 8),
  //                     Text('Connect'),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             ElevatedButton(
  //               onPressed: () {
  //                 showCupertinoDialog(
  //                   context: context,
  //                   builder: (BuildContext context) {
  //                     return CupertinoAlertDialog(
  //                       title: const Text('Join Call with Conference ID'),
  //                       content: Column(
  //                         children: [
  //                           const SizedBox(height: 10),
  //                           CupertinoTextField(
  //                             style: const TextStyle(
  //                               color: CupertinoColors.white,
  //                             ),
  //                             controller: conferenceIdController,
  //                             placeholder: 'Conference ID',
  //                             onChanged: (value) {
  //                               conferenceID = value;
  //                             },
  //                             keyboardType: TextInputType.number,
  //                           ),
  //                           // Error message displayed below the text field
  //                           if (conferenceIdController.text.isEmpty)
  //                             const Text(
  //                               'Please enter Conference ID',
  //                               style:
  //                                   TextStyle(color: CupertinoColors.systemRed),
  //                             ),
  //                         ],
  //                       ),
  //                       actions: <Widget>[
  //                         CupertinoDialogAction(
  //                           onPressed: () {
  //                             if (conferenceIdController.text.isEmpty) {
  //                               // Do nothing if the conference ID is empty
  //                             } else if (_formKey.currentState!.validate()) {
  //                               Navigator.pop(context);
  //                               navigateToConference();
  //                             }
  //                           },
  //                           child: const Text('Join'),
  //                         ),
  //                         CupertinoDialogAction(
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                           child: const Text('Cancel'),
  //                         ),
  //                       ],
  //                     );
  //                   },
  //                 );
  //               },
  //               child: const Text('Join with Conference ID'),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

