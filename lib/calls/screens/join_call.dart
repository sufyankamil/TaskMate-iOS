import 'package:flutter/material.dart';

class JoinCall extends StatefulWidget {
  const JoinCall({Key? key}) : super(key: key);

  @override
  _JoinCallState createState() => _JoinCallState();
}

class _JoinCallState extends State<JoinCall> {
  late TextEditingController _nameController;
  late TextEditingController _userIdController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _userIdController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Join Call',
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add logic to handle joining the call with provided name and user ID
                // You can access name and user ID using _nameController.text and _userIdController.text respectively
              },
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}
