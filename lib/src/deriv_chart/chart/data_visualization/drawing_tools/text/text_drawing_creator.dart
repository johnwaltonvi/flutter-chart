import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:flutter/material.dart';

import 'text_drawing.dart';

/// Creates an anchored text drawing with a single tap.
class TextDrawingCreator extends DrawingCreator<TextDrawing> {
  /// Initializes [TextDrawingCreator].
  const TextDrawingCreator({
    required OnAddDrawing<TextDrawing> onAddDrawing,
    required double Function(double) quoteFromCanvasY,
    Key? key,
  }) : super(
          key: key,
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
        );

  @override
  DrawingCreatorState<TextDrawing> createState() => _TextDrawingCreatorState();
}

class _TextDrawingCreatorState extends DrawingCreatorState<TextDrawing> {
  @override
  void onTap(TapUpDetails details) {
    super.onTap(details);

    if (isDrawingFinished) {
      return;
    }

    setState(() {
      position = details.localPosition;

      edgePoints.add(
        EdgePoint(
          epoch: epochFromX!(position!.dx),
          quote: widget.quoteFromCanvasY(position!.dy),
        ),
      );

      isDrawingFinished = true;

      drawingParts.addAll(<TextDrawing>[
        TextDrawing(
          drawingPart: DrawingParts.marker,
          edgePoint: edgePoints.first,
        ),
        TextDrawing(
          drawingPart: DrawingParts.line,
          edgePoint: edgePoints.first,
        ),
      ]);

      widget.onAddDrawing(
        drawingId,
        drawingParts,
        isDrawingFinished: isDrawingFinished,
        edgePoints: <EdgePoint>[...edgePoints],
      );
    });
  }
}
