import 'package:deriv_chart/src/add_ons/drawing_tools_ui/distance_constants.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/horizontal_ray/horizontal_ray_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// Horizontal ray drawing tool.
class HorizontalRayDrawing extends Drawing {
  /// Initializes [HorizontalRayDrawing].
  HorizontalRayDrawing({
    required this.drawingPart,
    this.startEdgePoint = const EdgePoint(),
    this.endEdgePoint = const EdgePoint(),
  });

  /// Initializes from JSON.
  factory HorizontalRayDrawing.fromJson(Map<String, dynamic> json) =>
      HorizontalRayDrawing(
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
  static const String nameKey = 'HorizontalRayDrawing';

  /// Part of a drawing.
  final DrawingParts drawingPart;

  /// Starting point of drawing.
  final EdgePoint startEdgePoint;

  /// Direction point of drawing.
  final EdgePoint endEdgePoint;

  final double _markerRadius = 10;

  Point? _startPoint;
  Point? _directionPoint;
  Offset? _rayStartOffset;
  Offset? _rayEndOffset;

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
    final rayConfig = config as HorizontalRayDrawingToolConfig;
    final edgePoints = rayConfig.edgePoints;
    final lineStyle = rayConfig.lineStyle;

    _startPoint = updatePositionCallback(edgePoints.first, draggableStartPoint);

    if (edgePoints.length > 1) {
      _directionPoint =
          updatePositionCallback(edgePoints.last, draggableEndPoint!);
    } else {
      _directionPoint =
          updatePositionCallback(endEdgePoint, draggableEndPoint!);
    }

    final startOffset = Offset(_startPoint!.x, _startPoint!.y);
    final directionX = _directionPoint!.x;
    final extendRight = directionX >= startOffset.dx;
    final rayStartX = extendRight
        ? startOffset.dx
        : startOffset.dx - DrawingToolDistance.horizontalDistance;
    final rayEndX = extendRight
        ? startOffset.dx + DrawingToolDistance.horizontalDistance
        : startOffset.dx;

    _rayStartOffset = Offset(rayStartX, startOffset.dy);
    _rayEndOffset = Offset(rayEndX, startOffset.dy);

    if (drawingPart == DrawingParts.marker) {
      final markerOffset = endEdgePoint.epoch == 0 && endEdgePoint.quote == 0
          ? startOffset
          : Offset(directionX, startOffset.dy);

      canvas.drawCircle(
        markerOffset,
        _markerRadius,
        drawingData.shouldHighlight
            ? paint.glowyCirclePaintStyle(lineStyle.color)
            : paint.transparentCirclePaintStyle(),
      );
      return;
    }

    if (rayConfig.pattern == DrawingPatterns.solid) {
      canvas.drawLine(
        _rayStartOffset!,
        _rayEndOffset!,
        drawingData.shouldHighlight
            ? paint.glowyLinePaintStyle(lineStyle.color, lineStyle.thickness)
            : paint.linePaintStyle(lineStyle.color, lineStyle.thickness),
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
    final rayConfig = config as HorizontalRayDrawingToolConfig;
    final directionOffset = _directionPoint == null
        ? null
        : Offset(_directionPoint!.x, _startPoint!.y);

    if (_startPoint == null ||
        _rayStartOffset == null ||
        _rayEndOffset == null) {
      return false;
    }

    final startOffset = Offset(_startPoint!.x, _startPoint!.y);
    final onStartPoint = (position - startOffset).distance <= _markerRadius;
    setIsOverStartPoint(isOverPoint: onStartPoint);

    final onEndPoint = directionOffset != null &&
        (position - directionOffset).distance <= _markerRadius;
    setIsOverEndPoint?.call(isOverPoint: onEndPoint);

    final minX = _rayStartOffset!.dx < _rayEndOffset!.dx
        ? _rayStartOffset!.dx
        : _rayEndOffset!.dx;
    final maxX = _rayStartOffset!.dx > _rayEndOffset!.dx
        ? _rayStartOffset!.dx
        : _rayEndOffset!.dx;

    final onLine = position.dx >= minX - 6 &&
        position.dx <= maxX + 6 &&
        (position.dy - startOffset.dy).abs() <=
            rayConfig.lineStyle.thickness + 6;

    return onStartPoint || onEndPoint || onLine;
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
}
