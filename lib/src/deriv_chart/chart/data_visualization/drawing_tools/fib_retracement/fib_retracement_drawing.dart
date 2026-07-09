import 'dart:math' as math;

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/fib_retracement/fib_level.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/fib_retracement/fib_retracement_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// Fib retracement drawing tool.
class FibRetracementDrawing extends Drawing {
  /// Initializes [FibRetracementDrawing].
  FibRetracementDrawing({
    required this.drawingPart,
    this.startEdgePoint = const EdgePoint(),
    this.endEdgePoint = const EdgePoint(),
  });

  /// Initializes from JSON.
  factory FibRetracementDrawing.fromJson(Map<String, dynamic> json) =>
      FibRetracementDrawing(
        drawingPart: _drawingPartFromJson(json['drawingPart']),
        startEdgePoint: json['startEdgePoint'] == null
            ? const EdgePoint()
            : EdgePoint.fromJson(
                json['startEdgePoint'] as Map<String, dynamic>),
        endEdgePoint: json['endEdgePoint'] == null
            ? const EdgePoint()
            : EdgePoint.fromJson(json['endEdgePoint'] as Map<String, dynamic>),
      );

  /// Key of drawing tool name property in JSON.
  static const String nameKey = 'FibRetracementDrawing';

  /// Part of a drawing.
  final DrawingParts drawingPart;

  /// Starting point of drawing.
  final EdgePoint startEdgePoint;

  /// Ending point of drawing.
  final EdgePoint endEdgePoint;

  final double _markerRadius = 10;

  Point? _startPoint;
  Point? _endPoint;
  double _lineLeft = 0;
  double _lineRight = 0;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'drawingPart': drawingPart.name,
        'startEdgePoint': startEdgePoint.toJson(),
        'endEdgePoint': endEdgePoint.toJson(),
        Drawing.classNameKey: nameKey,
      };

  @override
  bool needsRepaint(
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  }) =>
      true;

  @override
  void onPaint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    int Function(double x) epochFromX,
    double Function(double) quoteFromY,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DrawingData drawingData,
    DataSeries<Tick> series,
    Point Function(
      EdgePoint edgePoint,
      DraggableEdgePoint draggableEdgePoint,
    ) updatePositionCallback,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  }) {
    final paint = DrawingPaintStyle();
    final fibConfig = config as FibRetracementDrawingToolConfig;
    final edgePoints = fibConfig.edgePoints;

    _startPoint = updatePositionCallback(edgePoints.first, draggableStartPoint);
    if (edgePoints.length > 1) {
      _endPoint = updatePositionCallback(edgePoints.last, draggableEndPoint!);
    } else {
      _endPoint = updatePositionCallback(endEdgePoint, draggableEndPoint!);
    }

    final startOffset = Offset(_startPoint!.x, _startPoint!.y);
    final endOffset = Offset(_endPoint!.x, _endPoint!.y);
    final leftX = startOffset.dx < endOffset.dx ? startOffset.dx : endOffset.dx;
    final rightX =
        startOffset.dx > endOffset.dx ? startOffset.dx : endOffset.dx;

    _lineLeft = fibConfig.extend == FibExtendMode.left ||
            fibConfig.extend == FibExtendMode.both
        ? 0
        : leftX;
    _lineRight = fibConfig.extend == FibExtendMode.right ||
            fibConfig.extend == FibExtendMode.both
        ? size.width
        : rightX;

    if (drawingPart == DrawingParts.marker) {
      final markerOffset = endEdgePoint.epoch == 0 && endEdgePoint.quote == 0
          ? startOffset
          : endOffset;

      canvas.drawCircle(
        markerOffset,
        _markerRadius,
        drawingData.shouldHighlight
            ? paint.glowyCirclePaintStyle(fibConfig.lineStyle.color)
            : paint.transparentCirclePaintStyle(),
      );
      return;
    }

    final enabledLevels = _enabledLevels(fibConfig);
    double levelY(FibLevel level) =>
        startOffset.dy + ((endOffset.dy - startOffset.dy) * level.value);

    if (fibConfig.fillEnabled && enabledLevels.length > 1) {
      final sorted = List<FibLevel>.of(enabledLevels)
        ..sort((a, b) => a.value.compareTo(b.value));
      for (var i = 0; i < sorted.length - 1; i++) {
        final yA = levelY(sorted[i]);
        final yB = levelY(sorted[i + 1]);
        final fillPaint = Paint()
          ..color = _levelColor(fibConfig, sorted[i + 1])
              .withValues(alpha: fibConfig.fillOpacity.clamp(0.0, 1.0))
          ..style = PaintingStyle.fill;
        canvas.drawRect(
          Rect.fromLTRB(
            _lineLeft,
            math.min(yA, yB),
            _lineRight,
            math.max(yA, yB),
          ),
          fillPaint,
        );
      }
    }

    if (fibConfig.showTrendLine) {
      final trendPaint = drawingData.shouldHighlight
          ? paint.glowyLinePaintStyle(
              fibConfig.trendLineStyle.color,
              fibConfig.trendLineStyle.thickness,
            )
          : paint.linePaintStyle(
              fibConfig.trendLineStyle.color,
              fibConfig.trendLineStyle.thickness,
            );
      _paintStyledLine(
        canvas,
        startOffset,
        endOffset,
        trendPaint,
        fibConfig.trendLinePattern,
      );
    }

    for (final level in enabledLevels) {
      final y = levelY(level);
      final color = _levelColor(fibConfig, level);

      final linePaint = drawingData.shouldHighlight
          ? paint.glowyLinePaintStyle(color, fibConfig.lineStyle.thickness)
          : paint.linePaintStyle(color, fibConfig.lineStyle.thickness);

      _paintStyledLine(
        canvas,
        Offset(_lineLeft, y),
        Offset(_lineRight, y),
        linePaint,
        fibConfig.levelsPattern,
      );

      if (fibConfig.showLabels) {
        paintText(
          canvas,
          text: _labelText(fibConfig, level, quoteFromY(y)),
          anchor: Offset(_lineLeft + 6, y),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          anchorAlignment: Alignment.centerLeft,
        );
      }
    }
  }

  @override
  bool hitTest(
    Offset position,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DraggableEdgePoint draggableStartPoint,
    void Function({required bool isOverPoint}) setIsOverStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
    void Function({required bool isOverPoint})? setIsOverMiddlePoint,
    void Function({required bool isOverPoint})? setIsOverEndPoint,
  }) {
    final fibConfig = config as FibRetracementDrawingToolConfig;

    if (_startPoint == null || _endPoint == null) {
      return false;
    }

    final startOffset = Offset(_startPoint!.x, _startPoint!.y);
    final endOffset = Offset(_endPoint!.x, _endPoint!.y);

    final onStartPoint = (position - startOffset).distance <= _markerRadius;
    final onEndPoint = (position - endOffset).distance <= _markerRadius;

    setIsOverStartPoint(isOverPoint: onStartPoint);
    setIsOverEndPoint?.call(isOverPoint: onEndPoint);

    if (onStartPoint || onEndPoint) {
      return true;
    }

    final tolerance = fibConfig.lineStyle.thickness + 6;

    for (final level in _enabledLevels(fibConfig)) {
      final y =
          startOffset.dy + ((endOffset.dy - startOffset.dy) * level.value);
      final onLine = position.dx >= _lineLeft - 8 &&
          position.dx <= _lineRight + 8 &&
          (position.dy - y).abs() <= tolerance;
      if (onLine) {
        return true;
      }
    }

    if (fibConfig.showTrendLine &&
        _distanceToSegment(position, startOffset, endOffset) <=
            fibConfig.trendLineStyle.thickness + 6) {
      return true;
    }

    return false;
  }

  static List<FibLevel> _enabledLevels(
          FibRetracementDrawingToolConfig config) =>
      config.levels.where((level) => level.enabled).toList();

  static Color _levelColor(
          FibRetracementDrawingToolConfig config, FibLevel level) =>
      config.useOneColor ? config.lineStyle.color : level.color;

  static String _labelText(
    FibRetracementDrawingToolConfig config,
    FibLevel level,
    double price,
  ) {
    final percent = _formatLevel(level.value);
    if (config.labelMode == FibLabelMode.percentPrice) {
      return '$percent (${_formatPrice(price)})';
    }
    return percent;
  }

  static String _formatPrice(double price) {
    final magnitude = price.abs();
    if (magnitude >= 1000) {
      return price.toStringAsFixed(2);
    }
    if (magnitude == 0) {
      return '0';
    }
    final digits = 5 - (math.log(magnitude) / math.ln10).floor() - 1;
    return price.toStringAsFixed(digits.clamp(0, 8));
  }

  /// Draws a line from [a] to [b] with the given [pattern].
  static void _paintStyledLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint,
    DrawingPatterns pattern,
  ) {
    if (pattern == DrawingPatterns.solid) {
      canvas.drawLine(a, b, paint);
      return;
    }

    final dashWidth = pattern == DrawingPatterns.dashed ? 6.0 : 1.5;
    const dashSpace = 4.0;
    final total = (b - a).distance;
    if (total == 0) {
      return;
    }
    final direction = (b - a) / total;

    var travelled = 0.0;
    while (travelled < total) {
      final segmentEnd = math.min(travelled + dashWidth, total);
      canvas.drawLine(
        a + direction * travelled,
        a + direction * segmentEnd,
        paint,
      );
      travelled = segmentEnd + dashSpace;
    }
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final lengthSquared = ab.dx * ab.dx + ab.dy * ab.dy;
    if (lengthSquared == 0) {
      return (p - a).distance;
    }
    final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / lengthSquared)
        .clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }

  static DrawingParts _drawingPartFromJson(Object? value) {
    switch (value) {
      case 'marker':
        return DrawingParts.marker;
      case 'rectangle':
        return DrawingParts.rectangle;
      case 'line':
      default:
        return DrawingParts.line;
    }
  }

  static String _formatLevel(double level) {
    final percent = level * 100;
    final fixed = percent.toStringAsFixed(1);
    final trimmed =
        fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
    return '$trimmed%';
  }
}
