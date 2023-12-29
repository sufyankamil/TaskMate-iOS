import 'package:flutter/material.dart';
import 'package:flutter_tawk/flutter_tawk.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Support'),
      // ),
      body: Tawk(
        directChatLink:
            'https://tawk.to/chat/658d7cfe70c9f2407f840a3c/1hiob0hj1',
        visitor: TawkVisitor(
          name: 'John Doe',
          email: 'test@gmail.com',
        ),
        onLoad: () {
          print('Widget loaded successfully');
        },
        onLinkTap: (String url) {
          print('Link clicked: $url');
        },
      ),
    );
  }
}
