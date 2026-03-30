import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/misc/debounce.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Paints every existing drawing.
class DrawingPainter extends StatefulWidget {
  /// Initializes
  const DrawingPainter({
    required this.drawingData,
    required this.quoteToCanvasY,
    required this.quoteFromCanvasY,
    required this.onMoveDrawing,
    required this.setIsDrawingSelected,
    required this.isDrawingMoving,
    required this.selectedDrawingTool,
    required this.onMouseEnter,
    required this.onMouseExit,
    required this.series,
    required this.chartConfig,
    Key? key,
  }) : super(key: key);

  /// Selected drawing tool.
  final DrawingToolConfig? selectedDrawingTool;

  /// Contains each drawing data
  final DrawingData? drawingData;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// Whether a drawing is moved or not.
  final bool isDrawingMoving;

  @override
  _DrawingPainterState createState() => _DrawingPainterState();

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  /// Callback to check if any single part of a single drawing is moved
  /// regardless of knowing type of the drawing.
  final void Function({bool isDrawingMoved}) onMoveDrawing;

  /// Callback to set if drawing is selected (tapped).
  final void Function(DrawingData drawing) setIsDrawingSelected;

  /// Callback to notify mouse enter over the addon.
  final void Function() onMouseEnter;

  /// Callback to notify mouse exit over the addon.
  final void Function() onMouseExit;

  /// Series of tick
  final DataSeries<Tick> series;

  /// Chart's configuration.
  final ChartConfig chartConfig;
}

class _DrawingPainterState extends State<DrawingPainter> {
  late final GestureManagerState _gestureManager;

  bool _isDrawingDragged = false;
  DraggableEdgePoint _draggableStartPoint = DraggableEdgePoint();
  DraggableEdgePoint _draggableMiddlePoint = DraggableEdgePoint();
  DraggableEdgePoint _draggableEndPoint = DraggableEdgePoint();
  Offset? _previousPosition;
  bool isTouchHeld = false;
  bool isOverStartPoint = false;
  bool isOverMiddlePoint = false;
  bool isOverEndPoint = false;
  bool _gestureStartedOnThisDrawing = false;
  bool _scrollBlockApplied = false;
  bool _priorScrollBlocked = false;

  final Debounce _updateDebounce = Debounce();

  @override
  void initState() {
    super.initState();
    _gestureManager = context.read<GestureManagerState>()
      ..registerCallback(_handleTapUp)
      ..registerCallback(_handleScaleStart)
      ..registerCallback(_handlePanUpdate)
      ..registerCallback(_handleScaleEnd)
      ..registerCallback(_handleLongPressStart)
      ..registerCallback(_handleLongPressMoveUpdate)
      ..registerCallback(_handleLongPressEnd);
  }

  @override
  void dispose() {
    _gestureManager
      ..removeCallback(_handleTapUp)
      ..removeCallback(_handleScaleStart)
      ..removeCallback(_handlePanUpdate)
      ..removeCallback(_handleScaleEnd)
      ..removeCallback(_handleLongPressStart)
      ..removeCallback(_handleLongPressMoveUpdate)
      ..removeCallback(_handleLongPressEnd);
    super.dispose();
  }

  void _onMouseEnter() {
    setState(() {
      widget.drawingData!.isHovered = true;
    });
    widget.onMouseEnter();
  }

  void _onMouseExit() {
    setState(() {
      widget.drawingData!.isHovered = false;
    });
    widget.onMouseExit();
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    final Repository<DrawingToolConfig> repo =
        context.watch<Repository<DrawingToolConfig>>();

    return widget.drawingData != null
        ? MouseRegion(
            onEnter: (PointerEnterEvent event) {
              if (!isTouchHeld && !widget.isDrawingMoving) {
                _onMouseEnter();
              }
            },
            onExit: (PointerExitEvent event) {
              if (!isTouchHeld && !widget.isDrawingMoving) {
                _onMouseExit();
              }
            },
            hitTestBehavior: HitTestBehavior.deferToChild,
            child: RepaintBoundary(
              child: CustomPaint(
                foregroundPainter: _DrawingPainter(
                  drawingData: widget.drawingData!,
                  series: widget.series,
                  config: repo.items
                      .where((DrawingToolConfig config) =>
                          config.configId == widget.drawingData!.id)
                      .first,
                  theme: context.watch<ChartTheme>(),
                  chartConfig: widget.chartConfig,
                  epochFromX: xAxis.epochFromX,
                  epochToX: xAxis.xFromEpoch,
                  quoteToY: widget.quoteToCanvasY,
                  quoteFromY: widget.quoteFromCanvasY,
                  draggableStartPoint: _draggableStartPoint,
                  draggableMiddlePoint: _draggableMiddlePoint,
                  isTouchHeld: isTouchHeld,
                  isDrawingToolSelected: widget.selectedDrawingTool != null,
                  draggableEndPoint: _draggableEndPoint,
                  leftEpoch: xAxis.leftBoundEpoch,
                  rightEpoch: xAxis.rightBoundEpoch,
                  updatePositionCallback: (
                    EdgePoint edgePoint,
                    DraggableEdgePoint draggableEdgePoint,
                  ) =>
                      draggableEdgePoint.updatePosition(
                    edgePoint.epoch,
                    edgePoint.quote,
                    xAxis.xFromEpoch,
                    widget.quoteToCanvasY,
                  ),
                  setIsOverStartPoint: ({required bool isOverPoint}) {
                    isOverStartPoint = isOverPoint;
                  },
                  setIsOverMiddlePoint: ({required bool isOverPoint}) {
                    isOverMiddlePoint = isOverPoint;
                  },
                  setIsOverEndPoint: ({required bool isOverPoint}) {
                    isOverEndPoint = isOverPoint;
                  },
                ),
              ),
            ))
        : const SizedBox();
  }

  bool _hitTestDrawing({
    required Offset position,
    required double Function(int) epochToX,
    required double Function(double) quoteToY,
    required DrawingToolConfig config,
  }) {
    var overStart = false;
    var overMiddle = false;
    var overEnd = false;

    var isHit = false;
    for (final Drawing drawingPart in widget.drawingData!.drawingParts) {
      if (drawingPart.hitTest(
        position,
        epochToX,
        quoteToY,
        config,
        _draggableStartPoint,
        ({required bool isOverPoint}) {
          overStart = overStart || isOverPoint;
        },
        draggableMiddlePoint: _draggableMiddlePoint,
        draggableEndPoint: _draggableEndPoint,
        setIsOverMiddlePoint: ({required bool isOverPoint}) {
          overMiddle = overMiddle || isOverPoint;
        },
        setIsOverEndPoint: ({required bool isOverPoint}) {
          overEnd = overEnd || isOverPoint;
        },
      )) {
        isHit = true;
        break;
      }
    }

    isOverStartPoint = overStart;
    isOverMiddlePoint = overMiddle;
    isOverEndPoint = overEnd;

    return isHit;
  }

  void _updateDrawingToolConfig(Repository<DrawingToolConfig> repo) {
    _updateDebounce.run(() {
      final DrawingData drawingData = widget.drawingData!;
      final int index = repo.items.indexWhere(
        (DrawingToolConfig item) => item.configId == drawingData.id,
      );

      if (index == -1) {
        return;
      }

      final DrawingToolConfig config = repo.items[index];

      final DrawingToolConfig updatedConfig = config.copyWith(
        edgePoints: <EdgePoint>[
          _draggableStartPoint.getEdgePoint(),
          // TODO(Bahar-Deriv): Change the way storing edge points
          if (config.configId!.contains('Channel'))
            _draggableMiddlePoint.getEdgePoint(),
          _draggableEndPoint.getEdgePoint(),
        ],
      );
      repo.updateAt(index, updatedConfig);
    });
  }

  void _updateDrawingsMovement(XAxisModel xAxis) {
    if (widget.drawingData == null) {
      return;
    }

    for (final Drawing drawing in widget.drawingData!.drawingParts) {
      drawing.onDrawingMoved(
        xAxis.epochFromX,
        widget.series.entries!,
        _draggableStartPoint,
        middlePoint: _draggableMiddlePoint,
        endPoint: _draggableEndPoint,
      );
    }

    setState(() {});
  }

  void _applyPanUpdate({
    required DragUpdateDetails details,
    required XAxisModel xAxis,
    required Repository<DrawingToolConfig> repo,
  }) {
    if (!widget.drawingData!.isSelected || !widget.drawingData!.isDrawingFinished) {
      return;
    }

    setState(() {
      _isDrawingDragged = details.delta != Offset.zero;

      _draggableStartPoint = _draggableStartPoint.copyWith(
        isDrawingDragged: _isDrawingDragged,
      )..updatePositionWithLocalPositions(
          details.delta,
          xAxis,
          widget.quoteFromCanvasY,
          widget.quoteToCanvasY,
          isOtherEndDragged:
              _draggableEndPoint.isDragged || _draggableMiddlePoint.isDragged,
        );
      _draggableMiddlePoint = _draggableMiddlePoint.copyWith(
        isDrawingDragged: _isDrawingDragged,
      )..updatePositionWithLocalPositions(
          details.delta,
          xAxis,
          widget.quoteFromCanvasY,
          widget.quoteToCanvasY,
          isOtherEndDragged:
              _draggableEndPoint.isDragged || _draggableStartPoint.isDragged,
        );

      _draggableEndPoint = _draggableEndPoint.copyWith(
        isDrawingDragged: _isDrawingDragged,
      )..updatePositionWithLocalPositions(
          details.delta,
          xAxis,
          widget.quoteFromCanvasY,
          widget.quoteToCanvasY,
          isOtherEndDragged:
              _draggableStartPoint.isDragged || _draggableMiddlePoint.isDragged,
        );
    });

    _updateDrawingToolConfig(repo);
  }

  void _blockXAxisScroll(XAxisModel xAxis) {
    if (_scrollBlockApplied) {
      return;
    }
    _priorScrollBlocked = xAxis.isScrollBlocked;
    if (!_priorScrollBlocked) {
      xAxis.isScrollBlocked = true;
      _scrollBlockApplied = true;
    }
  }

  void _restoreXAxisScroll(XAxisModel xAxis) {
    if (!_scrollBlockApplied) {
      return;
    }
    xAxis.isScrollBlocked = _priorScrollBlocked;
    _scrollBlockApplied = false;
  }

  bool _shouldIgnoreGesture() {
    if (!mounted) {
      return true;
    }
    if (widget.drawingData == null) {
      return true;
    }
    if (widget.selectedDrawingTool != null) {
      return true;
    }
    return false;
  }

  DrawingToolConfig? _resolveConfig(Repository<DrawingToolConfig> repo) {
    final String drawingId = widget.drawingData!.id;
    final int index = repo.items.indexWhere(
      (DrawingToolConfig item) => item.configId == drawingId,
    );
    if (index == -1) {
      return null;
    }
    return repo.items[index];
  }

  void _handleTapUp(TapUpDetails details) {
    if (_shouldIgnoreGesture()) {
      return;
    }

    isTouchHeld = false;
    _gestureStartedOnThisDrawing = false;

    final XAxisModel xAxis = context.read<XAxisModel>();
    final Repository<DrawingToolConfig> repo =
        context.read<Repository<DrawingToolConfig>>();
    final DrawingToolConfig? config = _resolveConfig(repo);
    if (config == null) {
      return;
    }

    final bool isHit = _hitTestDrawing(
      position: details.localPosition,
      epochToX: xAxis.xFromEpoch,
      quoteToY: widget.quoteToCanvasY,
      config: config,
    );

    if (isHit) {
      widget.setIsDrawingSelected(widget.drawingData!);
      _updateDrawingsMovement(xAxis);
      widget.onMoveDrawing(isDrawingMoved: false);
      return;
    }

    if (widget.drawingData!.isDrawingFinished &&
        (widget.drawingData!.isSelected || widget.drawingData!.isHovered)) {
      setState(() {
        widget.drawingData!
          ..isSelected = false
          ..isHovered = false;
      });
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_shouldIgnoreGesture()) {
      return;
    }
    if (!widget.drawingData!.isDrawingFinished || !widget.drawingData!.isSelected) {
      _gestureStartedOnThisDrawing = false;
      return;
    }

    final XAxisModel xAxis = context.read<XAxisModel>();
    final Repository<DrawingToolConfig> repo =
        context.read<Repository<DrawingToolConfig>>();
    final DrawingToolConfig? config = _resolveConfig(repo);
    if (config == null) {
      _gestureStartedOnThisDrawing = false;
      return;
    }

    _gestureStartedOnThisDrawing = _hitTestDrawing(
      position: details.localFocalPoint,
      epochToX: xAxis.xFromEpoch,
      quoteToY: widget.quoteToCanvasY,
      config: config,
    );

    if (_gestureStartedOnThisDrawing) {
      setState(() {
        _draggableStartPoint = _draggableStartPoint.copyWith(
          isDragged: isOverStartPoint,
        );
        _draggableMiddlePoint = _draggableMiddlePoint.copyWith(
          isDragged: isOverMiddlePoint,
        );
        _draggableEndPoint = _draggableEndPoint.copyWith(
          isDragged: isOverEndPoint,
        );
      });
      _blockXAxisScroll(xAxis);
      widget.onMoveDrawing(isDrawingMoved: true);
      isTouchHeld = true;
      _updateDrawingsMovement(xAxis);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_shouldIgnoreGesture()) {
      return;
    }
    if (!_gestureStartedOnThisDrawing) {
      return;
    }

    final XAxisModel xAxis = context.read<XAxisModel>();
    final Repository<DrawingToolConfig> repo =
        context.read<Repository<DrawingToolConfig>>();

    _blockXAxisScroll(xAxis);
    _applyPanUpdate(details: details, xAxis: xAxis, repo: repo);
    _updateDrawingsMovement(xAxis);
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (!_gestureStartedOnThisDrawing) {
      return;
    }

    final XAxisModel xAxis = context.read<XAxisModel>();
    _restoreXAxisScroll(xAxis);
    _gestureStartedOnThisDrawing = false;
    isTouchHeld = false;
    setState(() {
      _draggableStartPoint = _draggableStartPoint.copyWith(isDragged: false);
      _draggableMiddlePoint = _draggableMiddlePoint.copyWith(isDragged: false);
      _draggableEndPoint = _draggableEndPoint.copyWith(isDragged: false);
    });
    widget.onMoveDrawing(isDrawingMoved: false);
    _onMouseExit();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (_shouldIgnoreGesture()) {
      return;
    }
    if (!widget.drawingData!.isDrawingFinished) {
      return;
    }

    final XAxisModel xAxis = context.read<XAxisModel>();
    final Repository<DrawingToolConfig> repo =
        context.read<Repository<DrawingToolConfig>>();
    final DrawingToolConfig? config = _resolveConfig(repo);
    if (config == null) {
      return;
    }

    final bool isHit = _hitTestDrawing(
      position: details.localPosition,
      epochToX: xAxis.xFromEpoch,
      quoteToY: widget.quoteToCanvasY,
      config: config,
    );
    if (!isHit) {
      return;
    }

    if (!widget.drawingData!.isSelected) {
      widget.setIsDrawingSelected(widget.drawingData!);
    }

    _gestureStartedOnThisDrawing = true;
    _blockXAxisScroll(xAxis);

    _draggableStartPoint = _draggableStartPoint.copyWith(
      isDragged: isOverStartPoint,
    );

    _draggableMiddlePoint = _draggableMiddlePoint.copyWith(
      isDragged: isOverMiddlePoint,
    );

    _draggableEndPoint = _draggableEndPoint.copyWith(
      isDragged: isOverEndPoint,
    );

    widget.onMoveDrawing(isDrawingMoved: true);
    isTouchHeld = true;
    _previousPosition = details.localPosition;
    _updateDrawingsMovement(xAxis);
  }

  DragUpdateDetails _convertLongPressToDrag(
    LongPressMoveUpdateDetails longPressDetails,
    Offset previousPosition,
  ) {
    final Offset delta = longPressDetails.localPosition - previousPosition;
    return DragUpdateDetails(
      delta: delta,
      globalPosition: longPressDetails.globalPosition,
      localPosition: longPressDetails.localPosition,
    );
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_shouldIgnoreGesture()) {
      return;
    }
    if (!_gestureStartedOnThisDrawing) {
      return;
    }
    if (_previousPosition == null) {
      return;
    }

    final XAxisModel xAxis = context.read<XAxisModel>();
    final Repository<DrawingToolConfig> repo =
        context.read<Repository<DrawingToolConfig>>();

    final DragUpdateDetails dragDetails =
        _convertLongPressToDrag(details, _previousPosition!);
    _previousPosition = details.localPosition;

    _applyPanUpdate(details: dragDetails, xAxis: xAxis, repo: repo);
    _updateDrawingsMovement(xAxis);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (!_gestureStartedOnThisDrawing) {
      return;
    }
    final XAxisModel xAxis = context.read<XAxisModel>();
    _restoreXAxisScroll(xAxis);
    _gestureStartedOnThisDrawing = false;
    widget.onMoveDrawing(isDrawingMoved: false);
    _onMouseExit();
    isTouchHeld = false;
    _draggableStartPoint = _draggableStartPoint.copyWith(isDragged: false);
    _draggableMiddlePoint = _draggableMiddlePoint.copyWith(isDragged: false);
    _draggableEndPoint = _draggableEndPoint.copyWith(isDragged: false);
    _updateDrawingsMovement(xAxis);
  }
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter({
    required this.drawingData,
    required this.series,
    required this.config,
    required this.theme,
    required this.chartConfig,
    required this.epochFromX,
    required this.epochToX,
    required this.quoteToY,
    required this.quoteFromY,
    required this.draggableStartPoint,
    required this.setIsOverStartPoint,
    required this.updatePositionCallback,
    required this.leftEpoch,
    required this.rightEpoch,
    this.isDrawingToolSelected = false,
    this.isTouchHeld = false,
    this.draggableMiddlePoint,
    this.draggableEndPoint,
    this.setIsOverMiddlePoint,
    this.setIsOverEndPoint,
  });

  final DrawingData drawingData;
  final DataSeries<Tick> series;
  final DrawingToolConfig config;
  final ChartTheme theme;
  final ChartConfig chartConfig;
  final bool isDrawingToolSelected;
  final bool isTouchHeld;
  final int Function(double x) epochFromX;
  final double Function(int x) epochToX;
  final double Function(double y) quoteToY;
  final DraggableEdgePoint draggableStartPoint;
  final DraggableEdgePoint? draggableMiddlePoint;
  final DraggableEdgePoint? draggableEndPoint;
  final void Function({required bool isOverPoint}) setIsOverStartPoint;
  final void Function({required bool isOverPoint})? setIsOverMiddlePoint;
  final void Function({required bool isOverPoint})? setIsOverEndPoint;
  final Point Function(
    EdgePoint edgePoint,
    DraggableEdgePoint draggableEdgePoint,
  ) updatePositionCallback;

  /// Current left epoch of the chart.
  final int leftEpoch;

  /// Current right epoch of the chart.
  final int rightEpoch;

  double Function(double) quoteFromY;

  @override
  void paint(Canvas canvas, Size size) {
    for (final Drawing drawingPart in drawingData.drawingParts) {
      YAxisConfig.instance.yAxisClipping(canvas, size, () {
        drawingPart.onPaint(
          canvas,
          size,
          theme,
          epochFromX,
          quoteFromY,
          epochToX,
          quoteToY,
          config,
          drawingData,
          series,
          updatePositionCallback,
          draggableStartPoint,
          draggableMiddlePoint: draggableMiddlePoint,
          draggableEndPoint: draggableEndPoint,
        );
      });

      drawingPart.onLabelPaint(
        canvas,
        size,
        theme,
        chartConfig,
        epochFromX,
        quoteFromY,
        epochToX,
        quoteToY,
        config,
        drawingData,
        series,
      );
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) => drawingData.shouldRepaint(
        oldDelegate.drawingData,
        leftEpoch,
        rightEpoch,
        draggableStartPoint,
        draggableEndPoint: draggableEndPoint,
      );

  @override
  bool shouldRebuildSemantics(_DrawingPainter oldDelegate) => false;

  @override
  bool hitTest(Offset position) {
    setIsOverStartPoint(isOverPoint: false);
    setIsOverMiddlePoint?.call(isOverPoint: false);
    setIsOverEndPoint?.call(isOverPoint: false);

    if (isDrawingToolSelected) {
      return false;
    }

    for (final Drawing drawingPart in drawingData.drawingParts) {
      if (drawingPart.hitTest(
        position,
        epochToX,
        quoteToY,
        config,
        draggableStartPoint,
        setIsOverStartPoint,
        draggableMiddlePoint: draggableMiddlePoint,
        draggableEndPoint: draggableEndPoint,
        setIsOverMiddlePoint: setIsOverMiddlePoint,
        setIsOverEndPoint: setIsOverEndPoint,
      )) {
        return true;
      }
    }
    return false;
  }
}
