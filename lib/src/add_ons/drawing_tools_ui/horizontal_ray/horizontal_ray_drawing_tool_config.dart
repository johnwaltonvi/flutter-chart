import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import 'horizontal_ray_drawing_tool_item.dart';

/// Horizontal ray drawing tool config.
class HorizontalRayDrawingToolConfig extends DrawingToolConfig {
  /// Initializes [HorizontalRayDrawingToolConfig].
  const HorizontalRayDrawingToolConfig({
    String? configId,
    DrawingData? drawingData,
    List<EdgePoint> edgePoints = const <EdgePoint>[],
    this.lineStyle =
        const LineStyle(color: CoreDesignTokens.coreColorSolidBlue700),
    this.pattern = DrawingPatterns.solid,
    super.number,
  }) : super(
          configId: configId,
          drawingData: drawingData,
          edgePoints: edgePoints,
        );

  /// Initializes from JSON.
  factory HorizontalRayDrawingToolConfig.fromJson(Map<String, dynamic> json) {
    final rawEdgePoints = json['edgePoints'] as List<dynamic>?;

    return HorizontalRayDrawingToolConfig(
      configId: json[DrawingToolConfig.configIdKey] as String?,
      drawingData: json['drawingData'] == null
          ? null
          : DrawingData.fromJson(json['drawingData'] as Map<String, dynamic>),
      edgePoints: rawEdgePoints == null
          ? const <EdgePoint>[]
          : rawEdgePoints
              .map((edgePoint) =>
                  EdgePoint.fromJson(edgePoint as Map<String, dynamic>))
              .toList(),
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(color: CoreDesignTokens.coreColorSolidBlue700)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      pattern: _patternFromJson(json['pattern']),
      number: (json['number'] as num?)?.toInt() ?? 0,
    );
  }

  /// Unique name for this drawing tool.
  static const String name = 'dt_horizontal_ray';

  /// Drawing tool line style.
  final LineStyle lineStyle;

  /// Drawing tool line pattern.
  final DrawingPatterns pattern;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'number': number,
        'drawingData': drawingData?.toJson(),
        'edgePoints':
            edgePoints.map((edgePoint) => edgePoint.toJson()).toList(),
        DrawingToolConfig.configIdKey: configId,
        'lineStyle': lineStyle.toJson(),
        'pattern': pattern.name,
        DrawingToolConfig.nameKey: name,
      };

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      HorizontalRayDrawingToolItem(
        config: this,
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );

  @override
  HorizontalRayDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) =>
      HorizontalRayDrawingToolConfig(
        configId: configId ?? this.configId,
        drawingData: drawingData ?? this.drawingData,
        edgePoints: edgePoints ?? this.edgePoints,
        lineStyle: lineStyle ?? this.lineStyle,
        pattern: pattern ?? this.pattern,
        number: number ?? this.number,
      );

  static DrawingPatterns _patternFromJson(Object? value) {
    switch (value) {
      case 'dotted':
        return DrawingPatterns.dotted;
      case 'dashed':
        return DrawingPatterns.dashed;
      case 'solid':
      default:
        return DrawingPatterns.solid;
    }
  }
}
