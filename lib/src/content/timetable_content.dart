import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart';

import '../controller.dart';
import '../event.dart';
import '../theme.dart';
import '../timetable.dart';
import '../utils/vertical_zoom.dart';
import 'hours_column.dart';
import 'multi_date_content.dart';

class TimetableContent<E extends Event> extends StatelessWidget {
  const TimetableContent({
    Key key,
    @required this.controller,
    @required this.eventBuilder,
    this.hourBuilder,
    this.hourColumnWidth,
    this.onEventBackgroundTap,
  })  : assert(controller != null),
        assert(eventBuilder != null),
        super(key: key);

  final TimetableController<E> controller;
  final EventBuilder<E> eventBuilder;
  final OnEventBackgroundTapCallback onEventBackgroundTap;
  final HourWidgetBuilder hourBuilder;
  final double hourColumnWidth;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final timetableTheme = context.timetableTheme;

    return VerticalZoom(
      initialZoom: controller.initialTimeRange.asInitialZoom(),
      minChildHeight:
          (timetableTheme?.minimumHourHeight ?? 16) * TimeConstants.hoursPerDay,
      maxChildHeight:
          (timetableTheme?.maximumHourHeight ?? 64) * TimeConstants.hoursPerDay,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: hourColumnWidth,
            child: HoursColumn(
              builder: hourBuilder,
              textDirection: context.directionality,
              textStyle: timetableTheme?.hourTextStyle ??
                  theme.textTheme.caption.copyWith(
                    color: context.theme.disabledOnBackground,
                  ),
            ),
          ),
          Expanded(
            child: MultiDateContent<E>(
              controller: controller,
              eventBuilder: eventBuilder,
              onEventBackgroundTap: onEventBackgroundTap,
            ),
          ),
        ],
      ),
    );
  }
}
