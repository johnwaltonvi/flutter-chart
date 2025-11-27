import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

import '../../data_painter.dart';
import '../../data_series.dart';
import '../ohlc_painting.dart';
import '../ohlc_painter.dart';

/// A [DataPainter] for painting CandleStick data.
class CandlePainter extends OhlcPainter {
  /// Initializes
  CandlePainter(DataSeries<Candle> series) : super(series);

  late Paint _linePaint;
  late Paint _candleBullishColorPaint;
  late Paint _candleBearishColorPaint;

  @override
  void onPaintCandle(
    Canvas canvas,
    OhlcPainting currentPainting,
    OhlcPainting prevPainting,
  ) {
    final CandleStyle style = series.style as CandleStyle? ?? theme.candleStyle;

    // Check if the current candle is bullish or bearish.
    final bool isBullishCandle = currentPainting.yOpen > currentPainting.yClose;

    _linePaint = Paint()
      ..color = isBullishCandle
          ? style.candleBullishWickColor
          : style.candleBearishWickColor
      ..strokeWidth = 1.2;

    final Rect candleRect = isBullishCandle
        ? Rect.fromLTRB(
            currentPainting.xCenter - currentPainting.width / 2,
            currentPainting.yClose,
            currentPainting.xCenter + currentPainting.width / 2,
            currentPainting.yOpen,
          )
        : Rect.fromLTRB(
            currentPainting.xCenter - currentPainting.width / 2,
            currentPainting.yOpen,
            currentPainting.xCenter + currentPainting.width / 2,
            currentPainting.yClose,
          );

    _candleBullishColorPaint = Paint()
      ..color = style.candleBullishBodyColor
      ..shader = style.candleBullishBodyGradient?.createShader(candleRect);
    _candleBearishColorPaint = Paint()
      ..color = style.candleBearishBodyColor
      ..shader = style.candleBearishBodyGradient?.createShader(candleRect);

    canvas.drawLine(
      Offset(currentPainting.xCenter, currentPainting.yHigh),
      Offset(currentPainting.xCenter, currentPainting.yLow),
      _linePaint,
    );

    if (currentPainting.yOpen == currentPainting.yClose) {
      canvas.drawLine(
        Offset(currentPainting.xCenter - currentPainting.width / 2,
            currentPainting.yOpen),
        Offset(currentPainting.xCenter + currentPainting.width / 2,
            currentPainting.yOpen),
        _linePaint,
      );
    } else if (isBullishCandle) {
      canvas.drawRect(candleRect, _candleBullishColorPaint);
    } else {
      canvas.drawRect(candleRect, _candleBearishColorPaint);
    }
  }
}
