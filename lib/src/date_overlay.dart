import 'dart:ui';

import 'package:dartx/dartx.dart';
import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

/// The base class of all overlays.
abstract class DateOverlay {
  const DateOverlay({
    @required this.id,
    @required this.start,
    @required this.end,
  })  : assert(id != null),
        assert(start != null),
        assert(end != null),
        assert(start <= end);

  /// A unique ID, used e.g. for animating events.
  final Object id;

  /// Start of the event.
  final LocalDateTime start;

  // End of the event; exclusive.
  final LocalDateTime end;

  @override
  bool operator ==(dynamic other) {
    return runtimeType == other.runtimeType &&
        id == other.id &&
        start == other.start &&
        end == other.end;
  }

  @override
  int get hashCode => hashList([runtimeType, id, start, end]);

  @override
  String toString() => id.toString();
}

extension TimetableOverlay on DateOverlay {
  bool intersectsDate(LocalDate date) =>
      intersectsInterval(DateInterval(date, date));

  bool intersectsInterval(DateInterval interval) {
    return start.calendarDate <= interval.end &&
        endDateInclusive >= interval.start;
  }

  LocalDate get endDateInclusive {
    if (start.calendarDate == end.calendarDate) {
      return end.calendarDate;
    }

    return (end - Period(nanoseconds: 1)).calendarDate;
  }

  DateInterval get intersectingDates =>
      DateInterval(start.calendarDate, endDateInclusive);
}

extension TimetableOverlayIterable<E extends DateOverlay> on Iterable<E> {

  Iterable<E> intersectingInterval(DateInterval interval) =>
      where((e) => e.intersectsInterval(interval));
  Iterable<E> intersectingDate(LocalDate date) =>
      where((e) => e.intersectsDate(date));

  List<E> sortedByStartLength() =>
      sortedBy((e) => e.start).thenByDescending((e) => e.end);
}
