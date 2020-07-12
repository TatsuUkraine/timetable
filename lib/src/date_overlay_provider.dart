import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:time_machine/time_machine.dart';

import 'controller.dart';
import 'data_provider.dart';
import 'date_overlay.dart';

/// Provides [DateOverlay]s to a [TimetableController].
///
/// We provide the following implementations:
/// - [DateOverlayProvider.list], if you have a non-changing list of [DateOverlay]s.
/// - [DateOverlayProvider.simpleStream], if you have a changing list of [DateOverlay]s.
/// - [DateOverlayProvider.stream], if your events may change or you have many events
///   and only want to load a relevant subset.
abstract class DateOverlayProvider implements DataProvider<DateOverlay> {
  const DateOverlayProvider();

  /// Creates an [DateOverlayProvider] based on a fixed list of [DateOverlay]s.
  ///
  /// See also:
  /// - [DateOverlayProvider]'s class comment for an overview of provided
  ///   implementations.
  factory DateOverlayProvider.list(List<DateOverlay> overlays) = ListDateOverlayProvider;

  /// Creates an [DateOverlayProvider] accepting a [Stream] of [DateOverlay]s.
  ///
  /// See also:
  /// - [DateOverlayProvider]'s class comment for an overview of provided
  ///   implementations.
  factory DateOverlayProvider.simpleStream(Stream<List<DateOverlay>> eventStream) {
    assert(eventStream != null);

    final baseStream = eventStream.publishValue();
    final subscription = baseStream.connect();
    return DateOverlayProvider.stream(
      overlayGetter: (dates) {
        return baseStream.map((e) {
          return e.intersectingInterval(dates);
        });
      },
      onDispose: subscription.cancel,
    );
  }

  /// Creates an [DateOverlayProvider] accepting a [Stream] of [DateOverlay]s based on the
  /// currently visible range.
  ///
  /// See also:
  /// - [DateOverlayProvider]'s class comment for an overview of provided
  ///   implementations.
  factory DateOverlayProvider.stream({
    @required StreamedDateOverlayGetter overlayGetter,
    VoidCallback onDispose,
  }) = StreamDateOverlayProvider;

  @override
  void onVisibleDatesChanged(DateInterval visibleRange) {}

  Stream<Iterable<DateOverlay>> getOverlaysIntersecting(LocalDate date);

  /// Discards any resources used by the object.
  ///
  /// After this is called, the object is not in a usable state and should be
  /// discarded.
  ///
  /// This method is usually called by [TimetableController].
  @override
  void dispose() {}
}

/// An [DateOverlayProvider] accepting a single, non-changing list of [DateOverlay]s.
///
/// See also:
/// - [DateOverlayProvider.simpleStream], if you have a few events, but they may
///   change.
/// - [DateOverlayProvider.stream], if your events change or you have lots of them.
class ListDateOverlayProvider extends DateOverlayProvider {
  ListDateOverlayProvider(List<DateOverlay> overlays)
      : assert(overlays != null),
        _overlays = overlays;

  final List<DateOverlay> _overlays;

  @override
  Stream<Iterable<DateOverlay>> getOverlaysIntersecting(LocalDate date) {
    return Stream.value(
      _overlays.intersectingDate(date)
    );
  }
}

mixin VisibleDatesStreamDateOverlayProviderMixin
    on DateOverlayProvider {
  final _visibleDates = BehaviorSubject<DateInterval>();
  ValueStream<DateInterval> get visibleDates => _visibleDates.stream;

  @mustCallSuper
  @override
  void onVisibleDatesChanged(DateInterval visibleRange) {
    _visibleDates.add(visibleRange);
  }

  @mustCallSuper
  @override
  void dispose() {
    _visibleDates.close();
  }
}

typedef StreamedDateOverlayGetter = Stream<Iterable<DateOverlay>> Function(
    DateInterval dates);

/// An [DateOverlayProvider] accepting a [Stream] of [DateOverlay]s based on the currently
/// visible range.
///
/// See also:
/// - [DateOverlayProvider.list], if you only have a few static [DateOverlay]s.
/// - [DateOverlayProvider.simpleStream], if you only have a few events that may
///   change.
class StreamDateOverlayProvider extends DateOverlayProvider
    with VisibleDatesStreamDateOverlayProviderMixin {
  StreamDateOverlayProvider({@required this.overlayGetter, this.onDispose})
      : assert(overlayGetter != null) {
    _overlays = visibleDates.switchMap(overlayGetter).publishValue();
    _overlaysSubscription = _overlays.connect();
  }

  final StreamedDateOverlayGetter overlayGetter;
  final VoidCallback onDispose;

  ValueConnectableStream<Iterable<DateOverlay>> _overlays;
  StreamSubscription<Iterable<DateOverlay>> _overlaysSubscription;

  @override
  Stream<Iterable<DateOverlay>> getOverlaysIntersecting(LocalDate date) {
    return _overlays.map((overlays) => overlays.intersectingDate(date));
  }

  @override
  void dispose() {
    _overlaysSubscription.cancel();
    onDispose?.call();
    super.dispose();
  }
}
