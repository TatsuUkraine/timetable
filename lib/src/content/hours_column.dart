import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

import '../timetable.dart';
import '../utils/utils.dart';
import 'hour_label.dart';

class HoursColumn extends StatelessWidget {
  const HoursColumn({
    Key key,
    this.builder,
    this.textStyle,
    this.textDirection,
  }) : super(key: key);

  final HourWidgetBuilder builder;
  final TextStyle textStyle;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Expanded(flex: 1, child: SizedBox.shrink()),
      ...innerDateHours.map((hour) {
        final time = LocalTime(hour, 0, 0);

        return Expanded(
          flex: 2,
          child: builder?.call(context, time) ?? Align(
            alignment: Alignment.centerRight,
            child: HourLabel(
              time: time,
              textStyle: textStyle,
              textDirection: textDirection,
            ),
          ),
        );
      }),
      const Expanded(flex: 1, child: SizedBox.shrink()),
    ],
  );

}