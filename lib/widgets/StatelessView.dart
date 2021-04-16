import 'package:flutter/material.dart';

abstract class StatelessView<T> extends StatelessWidget {
  final T widget;

  const StatelessView(this.widget, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context);
}
