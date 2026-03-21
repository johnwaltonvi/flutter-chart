import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/fib_retracement/fib_retracement_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
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

  static const List<double> _levels = <double>[
    0,
    0.236,
    0.382,
    0.5,
    0.618,
    0.786,
    1,
  ];

  /// Part of a drawing.
  final DrawingParts drawingPart;

  /// Starting point of drawing.
  final EdgePoint startEdgePoint;

  /// Ending point of drawing.
  final EdgePoint endEdgePoint;

  final double _markerRadius = 10;

  Point? _startPoint;
  Point? _endPoint;

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

    final linePaint = drawingData.shouldHighlight
        ? paint.glowyLinePaintStyle(
            fibConfig.lineStyle.color,
            fibConfig.lineStyle.thickness,
          )
        : paint.linePaintStyle(
            fibConfig.lineStyle.color,
            fibConfig.lineStyle.thickness,
          );

    final textStyle = TextStyle(
      color: fibConfig.lineStyle.color,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    for (final level in _levels) {
      final y = startOffset.dy + ((endOffset.dy - startOffset.dy) * level);

      canvas.drawLine(
        Offset(leftX, y),
        Offset(rightX, y),
        linePaint,
      );

      paintText(
        canvas,
        text: _formatLevel(level),
        anchor: Offset(leftX + 6, y),
        style: textStyle,
        anchorAlignment: Alignment.centerLeft,
      );
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
    final leftX = startOffset.dx < endOffset.dx ? startOffset.dx : endOffset.dx;
    final rightX =
        startOffset.dx > endOffset.dx ? startOffset.dx : endOffset.dx;

    final onStartPoint = (position - startOffset).distance <= _markerRadius;
    final onEndPoint = (position - endOffset).distance <= _markerRadius;

    setIsOverStartPoint(isOverPoint: onStartPoint);
    setIsOverEndPoint?.call(isOverPoint: onEndPoint);

    if (onStartPoint || onEndPoint) {
      return true;
    }

    for (final level in _levels) {
      final y = startOffset.dy + ((endOffset.dy - startOffset.dy) * level);
      final onLine = position.dx >= leftX - 8 &&
          position.dx <= rightX + 8 &&
          (position.dy - y).abs() <= fibConfig.lineStyle.thickness + 6;
      if (onLine) {
        return true;
      }
    }

    return false;
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
