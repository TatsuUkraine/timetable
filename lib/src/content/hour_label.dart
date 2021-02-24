import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

class HourLabel extends StatelessWidget {
  const HourLabel({
    Key key,
    @required this.time,
    this.textStyle,
    this.textDirection,
  }) : super(key: key);

  /// Hour that needs to be rendered
  final LocalTime time;

  /// Text style for label
  final TextStyle textStyle;

  /// Label direction
  final TextDirection textDirection;

  static final _pattern = LocalTimePattern.createWithCurrentCulture('HH:mm');

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 12),
    child: Text(
      _pattern.format(time),
      style: textStyle,
      textDirection: textDirection,
    ),
  );
}