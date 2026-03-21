import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:flutter/material.dart';

import 'fib_retracement_drawing.dart';

/// Creates a fib retracement drawing piece by piece collected on every gesture.
class FibRetracementDrawingCreator
    extends DrawingCreator<FibRetracementDrawing> {
  /// Initializes [FibRetracementDrawingCreator].
  const FibRetracementDrawingCreator({
    required OnAddDrawing<FibRetracementDrawing> onAddDrawing,
    required double Function(double) quoteFromCanvasY,
    required this.clearDrawingToolSelection,
    required this.removeUnfinishedDrawing,
    Key? key,
  }) : super(
          key: key,
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
        );

  /// Callback to clear drawing tool selection.
  final VoidCallback clearDrawingToolSelection;

  /// Callback to remove specific drawing from the list of drawings.
  final VoidCallback removeUnfinishedDrawing;

  @override
  DrawingCreatorState<FibRetracementDrawing> createState() =>
      _FibRetracementDrawingCreatorState();
}

class _FibRetracementDrawingCreatorState
    extends DrawingCreatorState<FibRetracementDrawing> {
  bool _isPenDown = false;

  @override
  void onTap(TapUpDetails details) {
    super.onTap(details);
    final creator = widget as FibRetracementDrawingCreator;

    if (isDrawingFinished) {
      return;
    }

    setState(() {
      position = details.localPosition;
      tapCount++;

      if (!_isPenDown) {
        edgePoints.add(
          EdgePoint(
            epoch: epochFromX!(position!.dx),
            quote: widget.quoteFromCanvasY(position!.dy),
          ),
        );
        _isPenDown = true;

        drawingParts.add(
          FibRetracementDrawing(
            drawingPart: DrawingParts.marker,
            startEdgePoint: edgePoints.first,
          ),
        );
      } else {
        _isPenDown = false;
        isDrawingFinished = true;
        final currentTap = tapCount - 1;
        final previousTap = tapCount - 2;

        edgePoints.add(
          EdgePoint(
            epoch: epochFromX!(position!.dx),
            quote: widget.quoteFromCanvasY(position!.dy),
          ),
        );

        if (edgePoints[1] == edgePoints.first) {
          creator.removeUnfinishedDrawing();
          creator.clearDrawingToolSelection();
          return;
        }

        drawingParts.addAll(<FibRetracementDrawing>[
          FibRetracementDrawing(
            drawingPart: DrawingParts.marker,
            endEdgePoint: edgePoints[currentTap],
          ),
          FibRetracementDrawing(
            drawingPart: DrawingParts.line,
            startEdgePoint: edgePoints[previousTap],
            endEdgePoint: edgePoints[currentTap],
          ),
        ]);
      }

      widget.onAddDrawing(
        drawingId,
        drawingParts,
        isDrawingFinished: isDrawingFinished,
        edgePoints: <EdgePoint>[...edgePoints],
      );
    });
  }
}
