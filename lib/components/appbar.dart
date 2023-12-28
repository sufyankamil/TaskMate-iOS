import 'package:flutter/material.dart';

AppBar buildAppBar({
  required String appBarTitle,
  bool? centerTitle,
  List<Widget>? actionWidgets,
}) =>
    AppBar(
      title: Text(appBarTitle),
      centerTitle: centerTitle ?? false,
      backgroundColor: Colors.transparent,
      actions: actionWidgets ?? [],
    );
