import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:deriv_chart/src/models/chart_axis_config.dart';

part 'chart_config.g.dart';

/// Available time formats for axes and tooltips.
enum TimeFormat {
  @JsonValue('twenty_four_hour')
  twentyFourHour,
  @JsonValue('twelve_hour')
  twelveHour,
}

/// Chart's general configuration.
@immutable
@JsonSerializable()
class ChartConfig {
  /// Initializes chart's general configuration.
  const ChartConfig({
    required this.granularity,
    this.chartAxisConfig = const ChartAxisConfig(),
    this.pipSize = 4,
    this.snapMarkersToIntervals = true,
    this.timeFormat = TimeFormat.twentyFourHour,
  });

  /// Initializes from JSON.
  factory ChartConfig.fromJson(Map<String, dynamic> json) =>
      _$ChartConfigFromJson(json);

  /// Serialization to JSON. Serves as value in key-value storage.
  Map<String, dynamic> toJson() => _$ChartConfigToJson(this);

  /// PipSize, number of decimal digits when showing prices on the chart.
  final int pipSize;

  /// Granularity.
  final int granularity;

  /// Whether markers' x-positions should snap to interval buckets (e.g., candle).
  ///
  /// When true, marker epochs are snapped to the current granularity bucket
  /// for rendering, aligning markers to candle centerlines on chart.
  final bool snapMarkersToIntervals;

  /// Preferred output format for x-axis labels and crosshair timestamps.
  final TimeFormat timeFormat;

  /// Chart Axis configuration.
  final ChartAxisConfig chartAxisConfig;

  @override
  bool operator ==(covariant ChartConfig other) =>
      pipSize == other.pipSize &&
      granularity == other.granularity &&
      snapMarkersToIntervals == other.snapMarkersToIntervals &&
      timeFormat == other.timeFormat;

  @override
  int get hashCode => Object.hash(
        pipSize,
        granularity,
        snapMarkersToIntervals,
        timeFormat,
      );
}
