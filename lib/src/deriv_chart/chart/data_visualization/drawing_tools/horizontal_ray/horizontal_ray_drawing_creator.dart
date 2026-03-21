import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:flutter/material.dart';

import 'horizontal_ray_drawing.dart';

/// Creates a horizontal ray drawing piece by piece collected on every gesture.
class HorizontalRayDrawingCreator extends DrawingCreator<HorizontalRayDrawing> {
  /// Initializes [HorizontalRayDrawingCreator].
  const HorizontalRayDrawingCreator({
    required OnAddDrawing<HorizontalRayDrawing> onAddDrawing,
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
  DrawingCreatorState<HorizontalRayDrawing> createState() =>
      _HorizontalRayDrawingCreatorState();
}

class _HorizontalRayDrawingCreatorState
    extends DrawingCreatorState<HorizontalRayDrawing> {
  bool _isPenDown = false;

  @override
  void onTap(TapUpDetails details) {
    super.onTap(details);
    final creator = widget as HorizontalRayDrawingCreator;

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
          HorizontalRayDrawing(
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

        drawingParts.addAll(<HorizontalRayDrawing>[
          HorizontalRayDrawing(
            drawingPart: DrawingParts.marker,
            endEdgePoint: edgePoints[currentTap],
          ),
          HorizontalRayDrawing(
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
