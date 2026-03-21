import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import 'text_drawing_tool_item.dart';

/// Text drawing tool config.
class TextDrawingToolConfig extends DrawingToolConfig {
  /// Initializes [TextDrawingToolConfig].
  const TextDrawingToolConfig({
    String? configId,
    DrawingData? drawingData,
    List<EdgePoint> edgePoints = const <EdgePoint>[],
    this.text = defaultText,
    this.lineStyle =
        const LineStyle(color: CoreDesignTokens.coreColorSolidBlue700),
    super.number,
  }) : super(
          configId: configId,
          drawingData: drawingData,
          edgePoints: edgePoints,
        );

  /// Initializes from JSON.
  factory TextDrawingToolConfig.fromJson(Map<String, dynamic> json) {
    final rawEdgePoints = json['edgePoints'] as List<dynamic>?;

    return TextDrawingToolConfig(
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
      text: (json['text'] as String?) ?? defaultText,
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(color: CoreDesignTokens.coreColorSolidBlue700)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      number: (json['number'] as num?)?.toInt() ?? 0,
    );
  }

  /// Unique name for this drawing tool.
  static const String name = 'dt_text';

  /// Fallback text shown for a new note.
  static const String defaultText = 'Text';

  /// Note text.
  final String text;

  /// Accent color for the note border, anchor, and text.
  final LineStyle lineStyle;

  /// Returns the visible note content.
  String get resolvedText {
    final trimmed = text.trim();
    return trimmed.isEmpty ? defaultText : trimmed;
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'number': number,
        'drawingData': drawingData?.toJson(),
        'edgePoints':
            edgePoints.map((edgePoint) => edgePoint.toJson()).toList(),
        DrawingToolConfig.configIdKey: configId,
        'text': text,
        'lineStyle': lineStyle.toJson(),
        DrawingToolConfig.nameKey: name,
      };

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      TextDrawingToolItem(
        config: this,
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );

  @override
  TextDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) =>
      TextDrawingToolConfig(
        configId: configId ?? this.configId,
        drawingData: drawingData ?? this.drawingData,
        edgePoints: edgePoints ?? this.edgePoints,
        text: text,
        lineStyle: lineStyle ?? this.lineStyle,
        number: number ?? this.number,
      );
}
