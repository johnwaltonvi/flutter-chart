import 'package:deriv_chart/src/models/tick.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Candle class.
@immutable
class Candle extends Tick with EquatableMixin {
  /// Initializes a candle class.
  const Candle({
    required int epoch,
    required this.high,
    required this.low,
    required this.open,
    required this.close,
    this.volume,
    this.trades,
    int? currentEpoch,
  })  : currentEpoch = currentEpoch ?? epoch,
        super(epoch: epoch, quote: close);

  /// Initializes a candle class with only the given parameters or non given.
  const Candle.noParam(
    int epoch,
    double open,
    double close,
    double high,
    double low, {
    int? currentEpoch,
  }) : this(
          epoch: epoch,
          open: open,
          close: close,
          high: high,
          low: low,
          currentEpoch: currentEpoch,
        );

  /// High value
  @override
  final double high;

  /// Low value.
  @override
  final double low;

  /// Open value.
  @override
  final double open;

  /// Close value.
  @override
  final double close;

  /// Optional volume value associated with this candle.
  final double? volume;

  /// Optional trades count associated with this candle.
  final double? trades;

  /// The current time value of candle (it is the current time of the candle
  /// rather than start of it).
  final int currentEpoch;

  /// Creates a copy of this object.
  Candle copyWith({
    int? epoch,
    double? high,
    double? low,
    double? open,
    double? close,
    double? volume,
    double? trades,
    int? currentEpoch,
  }) =>
      Candle(
        epoch: epoch ?? this.epoch,
        high: high ?? this.high,
        low: low ?? this.low,
        open: open ?? this.open,
        close: close ?? this.close,
        volume: volume ?? this.volume,
        trades: trades ?? this.trades,
        currentEpoch: currentEpoch ?? this.currentEpoch,
      );

  @override
  String toString() =>
      'Candle(epoch: $epoch, high: $high, low: $low, open: $open, close: '
      '$close, volume: $volume, trades: $trades, currentEpoch: $currentEpoch)';

  @override
  List<Object?> get props => <Object?>[
        epoch,
        open,
        close,
        high,
        low,
        volume,
        trades,
      ];
}
