import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveSessions extends ConsumerStatefulWidget {
  final String sessionId;

  const ActiveSessions({required this.sessionId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ActiveSessionsState();
}

class _ActiveSessionsState extends ConsumerState<ActiveSessions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(widget.sessionId),
      ),
    );
  }
}
