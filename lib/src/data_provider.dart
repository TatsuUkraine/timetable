import 'package:time_machine/time_machine.dart';

import 'controller.dart';

abstract class DataProvider<I> {

  void onVisibleDatesChanged(DateInterval visibleRange);

  /// Discards any resources used by the object.
  ///
  /// After this is called, the object is not in a usable state and should be
  /// discarded.
  ///
  /// This method is usually called by [TimetableController].
  void dispose();
}