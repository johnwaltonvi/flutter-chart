import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/static_indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/raw_bar_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';

/// Volume indicator config.
class VolumeIndicatorConfig extends IndicatorConfig {
  /// Initializes the config.
  const VolumeIndicatorConfig({
    this.barStyle = const BarStyle(),
    bool showLastIndicator = false,
    int pipSize = 2,
    String? title,
    super.number,
  }) : super(
          isOverlay: false,
          pipSize: pipSize,
          showLastIndicator: showLastIndicator,
          title: title ?? 'Volume',
        );

  /// Initializes from JSON.
  factory VolumeIndicatorConfig.fromJson(Map<String, dynamic> json) {
    final rawStyle = json['barStyle'];
    return VolumeIndicatorConfig(
      barStyle: rawStyle is Map<String, dynamic>
          ? BarStyle.fromJson(rawStyle)
          : const BarStyle(),
      showLastIndicator: json['showLastIndicator'] == true,
      pipSize: (json['pipSize'] as num?)?.toInt() ?? 2,
      title: json['title'] as String?,
      number: (json['number'] as num?)?.toInt() ?? 0,
    );
  }

  /// Unique config name.
  static const String name = 'volume';

  /// Bar style used for the histogram.
  final BarStyle barStyle;

  @override
  bool canRender(IndicatorInput indicatorInput) {
    return indicatorInput.entries.any((entry) {
      return entry is Candle && (entry.volume ?? 0) > 0;
    });
  }

  @override
  Series getSeries(IndicatorInput indicatorInput) {
    final entries = indicatorInput.entries
        .whereType<Candle>()
        .map(
          (candle) => Tick(
            epoch: candle.epoch,
            quote: (candle.volume ?? 0).toDouble(),
          ),
        )
        .toList(growable: false);

    return RawBarSeries(
      entries,
      id: 'Volume${number > 0 ? '_$number' : ''}',
      style: barStyle,
      title: title,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        IndicatorConfig.nameKey: name,
        'title': title,
        'showLastIndicator': showLastIndicator,
        'pipSize': pipSize,
        'number': number,
        'barStyle': barStyle.toJson(),
      };

  @override
  String get shortTitle => 'Volume';

  @override
  String get configSummary => 'Bars';

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) {
    return StaticIndicatorItem(
      title: title,
      config: this,
      updateIndicator: updateIndicator,
      deleteIndicator: deleteIndicator,
      description:
          'Shows raw candle volume bars. This panel hides itself when the active dataset has no positive volume values.',
    );
  }

  @override
  VolumeIndicatorConfig copyWith({
    BarStyle? barStyle,
    String? title,
    bool? showLastIndicator,
    int? pipSize,
    int? number,
  }) {
    return VolumeIndicatorConfig(
      barStyle: barStyle ?? this.barStyle,
      title: title ?? this.title,
      showLastIndicator: showLastIndicator ?? this.showLastIndicator,
      pipSize: pipSize ?? this.pipSize,
      number: number ?? this.number,
    );
  }
}
