import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_painters/bar_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_dot_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_line_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:flutter/material.dart';

/// A basic histogram series backed by raw [Tick] values.
class RawBarSeries extends DataSeries<Tick> {
  /// Initializes the series.
  RawBarSeries(
    List<Tick> entries, {
    required this.title,
    String? id,
    BarStyle? style,
  }) : super(
          entries,
          id: id ?? title,
          style: style,
        );

  /// User-facing series title.
  final String title;

  @override
  SeriesPainter<DataSeries<Tick>> createPainter() => BarPainter(
        this,
        checkColorCallback: ({
          required double previousQuote,
          required double currentQuote,
        }) =>
            currentQuote >= previousQuote,
      );

  @override
  Widget getCrossHairInfo(
    Tick crossHairTick,
    int pipSize,
    ChartTheme theme,
    CrosshairVariant crosshairVariant,
  ) {
    final value = crossHairTick.quote;
    final bool showWholeNumber = value % 1 == 0;
    final int fractionDigits = showWholeNumber ? 0 : pipSize.clamp(0, 4);

    return Text(
      value.toStringAsFixed(fractionDigits),
      style: const TextStyle(fontSize: 16),
    );
  }

  @override
  CrosshairHighlightPainter getCrosshairHighlightPainter(
    Tick crosshairTick,
    double Function(double) quoteToY,
    double xCenter,
    int granularity,
    double Function(int) xFromEpoch,
    ChartTheme theme,
  ) {
    return CrosshairLineHighlightPainter(
      tick: crosshairTick,
      quoteToY: quoteToY,
      xCenter: xCenter,
      pointColor: Colors.transparent,
      pointSize: 0,
    );
  }

  @override
  CrosshairDotPainter getCrosshairDotPainter(ChartTheme theme) {
    return CrosshairDotPainter(
      dotColor: theme.currentSpotDotColor,
      dotBorderColor: theme.currentSpotDotEffect,
    );
  }

  @override
  double getCrosshairDetailsBoxHeight() => 50;

  @override
  Tick createVirtualTick(int epoch, double quote) {
    return Tick(epoch: epoch, quote: quote);
  }

  @override
  double maxValueOf(Tick t) => t.quote;

  @override
  double minValueOf(Tick t) => t.quote;
}
