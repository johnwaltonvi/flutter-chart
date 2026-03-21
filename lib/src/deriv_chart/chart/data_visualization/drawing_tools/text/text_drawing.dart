import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/text/text_drawing_tool_config.dart';
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

/// Text drawing tool.
class TextDrawing extends Drawing {
  /// Initializes [TextDrawing].
  TextDrawing({
    required this.drawingPart,
    this.edgePoint = const EdgePoint(),
  });

  /// Initializes from JSON.
  factory TextDrawing.fromJson(Map<String, dynamic> json) => TextDrawing(
        drawingPart: _drawingPartFromJson(json['drawingPart']),
        edgePoint: json['edgePoint'] == null
            ? const EdgePoint()
            : EdgePoint.fromJson(json['edgePoint'] as Map<String, dynamic>),
      );

  /// Key of drawing tool name property in JSON.
  static const String nameKey = 'TextDrawing';

  /// Part of a drawing.
  final DrawingParts drawingPart;

  /// Anchor point of drawing.
  final EdgePoint edgePoint;

  final double _markerRadius = 10;

  Point? _anchorPoint;
  Rect? _bubbleRect;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'drawingPart': drawingPart.name,
        'edgePoint': edgePoint.toJson(),
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
    final textConfig = config as TextDrawingToolConfig;
    final anchorEdgePoint =
        textConfig.edgePoints.isEmpty ? edgePoint : textConfig.edgePoints.first;

    _anchorPoint = updatePositionCallback(anchorEdgePoint, draggableStartPoint);

    final anchorOffset = Offset(_anchorPoint!.x, _anchorPoint!.y);

    if (drawingPart == DrawingParts.marker) {
      if (drawingData.shouldHighlight) {
        canvas.drawCircle(
          anchorOffset,
          _markerRadius,
          paint.glowyCirclePaintStyle(textConfig.lineStyle.color),
        );
      }
      return;
    }

    final textStyle = TextStyle(
      color: textConfig.lineStyle.color,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );
    final textPainter = makeTextPainter(textConfig.resolvedText, textStyle);

    const horizontalPadding = 8.0;
    const verticalPadding = 6.0;
    final bubbleWidth = textPainter.width + horizontalPadding * 2;
    final bubbleHeight = textPainter.height + verticalPadding * 2;

    var bubbleLeft = anchorOffset.dx + 12;
    var bubbleTop = anchorOffset.dy - bubbleHeight - 12;

    if (bubbleLeft + bubbleWidth > size.width - 8) {
      bubbleLeft = anchorOffset.dx - bubbleWidth - 12;
    }
    if (bubbleLeft < 8) {
      bubbleLeft = 8;
    }
    if (bubbleTop < 8) {
      bubbleTop = anchorOffset.dy + 12;
    }
    if (bubbleTop + bubbleHeight > size.height - 8) {
      bubbleTop = size.height - bubbleHeight - 8;
    }

    _bubbleRect = Rect.fromLTWH(
      bubbleLeft,
      bubbleTop,
      bubbleWidth,
      bubbleHeight,
    );

    final bubbleCenterY = _bubbleRect!.top + (_bubbleRect!.height / 2);
    final bubbleAnchor = bubbleLeft > anchorOffset.dx
        ? Offset(_bubbleRect!.left, bubbleCenterY)
        : Offset(_bubbleRect!.right, bubbleCenterY);

    final connectorPaint = drawingData.shouldHighlight
        ? paint.glowyLinePaintStyle(
            textConfig.lineStyle.color,
            textConfig.lineStyle.thickness,
          )
        : paint.linePaintStyle(
            textConfig.lineStyle.color,
            textConfig.lineStyle.thickness,
          );

    canvas.drawLine(anchorOffset, bubbleAnchor, connectorPaint);

    final bubbleRRect = RRect.fromRectAndRadius(
      _bubbleRect!,
      const Radius.circular(8),
    );

    canvas
      ..drawRRect(
        bubbleRRect,
        Paint()..color = Colors.black.withValues(alpha: 0.74),
      )
      ..drawRRect(
        bubbleRRect,
        Paint()
          ..color = textConfig.lineStyle.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = drawingData.shouldHighlight ? 2 : 1,
      );

    paintWithTextPainter(
      canvas,
      painter: textPainter,
      anchor: Offset(
        _bubbleRect!.left + horizontalPadding,
        _bubbleRect!.top + verticalPadding,
      ),
      anchorAlignment: Alignment.topLeft,
    );

    if (drawingData.shouldHighlight) {
      canvas.drawCircle(
        anchorOffset,
        _markerRadius,
        paint.glowyCirclePaintStyle(textConfig.lineStyle.color),
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
    if (_anchorPoint == null) {
      return false;
    }

    final anchorOffset = Offset(_anchorPoint!.x, _anchorPoint!.y);
    final onAnchor = (position - anchorOffset).distance <= _markerRadius;
    setIsOverStartPoint(isOverPoint: onAnchor);

    if (onAnchor) {
      return true;
    }

    return _bubbleRect?.contains(position) ?? false;
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
