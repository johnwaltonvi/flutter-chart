import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import 'fib_level.dart';
import 'fib_retracement_drawing_tool_item.dart';

/// Fib retracement drawing tool config.
class FibRetracementDrawingToolConfig extends DrawingToolConfig {
  /// Initializes [FibRetracementDrawingToolConfig].
  const FibRetracementDrawingToolConfig({
    String? configId,
    DrawingData? drawingData,
    List<EdgePoint> edgePoints = const <EdgePoint>[],
    this.lineStyle = const LineStyle(color: Color(0xFF787B86)),
    this.levels = defaultLevels,
    this.showTrendLine = true,
    this.trendLineStyle = const LineStyle(color: Color(0xFF787B86)),
    this.trendLinePattern = DrawingPatterns.dashed,
    this.levelsPattern = DrawingPatterns.solid,
    this.useOneColor = false,
    this.fillEnabled = true,
    this.fillOpacity = 0.1,
    this.extend = FibExtendMode.none,
    this.showLabels = true,
    this.labelMode = FibLabelMode.percent,
    super.number,
  }) : super(
          configId: configId,
          drawingData: drawingData,
          edgePoints: edgePoints,
        );

  /// Initializes from JSON.
  ///
  /// Payloads without [styleVersionKey] are legacy single-color drawings;
  /// they keep their identity/position fields and adopt the current default
  /// style (per-level colored palette).
  factory FibRetracementDrawingToolConfig.fromJson(Map<String, dynamic> json) {
    final rawEdgePoints = json['edgePoints'] as List<dynamic>?;

    final configId = json[DrawingToolConfig.configIdKey] as String?;
    final drawingData = json['drawingData'] == null
        ? null
        : DrawingData.fromJson(json['drawingData'] as Map<String, dynamic>);
    final edgePoints = rawEdgePoints == null
        ? const <EdgePoint>[]
        : rawEdgePoints
            .map((edgePoint) =>
                EdgePoint.fromJson(edgePoint as Map<String, dynamic>))
            .toList();
    final number = (json['number'] as num?)?.toInt() ?? 0;

    if (json[styleVersionKey] == null) {
      // Legacy payload: identity/position only, fresh default style.
      return FibRetracementDrawingToolConfig(
        configId: configId,
        drawingData: drawingData,
        edgePoints: edgePoints,
        number: number,
      );
    }

    const defaults = FibRetracementDrawingToolConfig();

    final rawLevels = json['levels'] as List<dynamic>?;

    return FibRetracementDrawingToolConfig(
      configId: configId,
      drawingData: drawingData,
      edgePoints: edgePoints,
      number: number,
      lineStyle: json['lineStyle'] == null
          ? defaults.lineStyle
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      levels: rawLevels == null || rawLevels.isEmpty
          ? defaultLevels
          : rawLevels
              .map((level) =>
                  FibLevel.fromJson(level as Map<String, dynamic>))
              .toList(),
      showTrendLine: json['showTrendLine'] as bool? ?? defaults.showTrendLine,
      trendLineStyle: json['trendLineStyle'] == null
          ? defaults.trendLineStyle
          : LineStyle.fromJson(json['trendLineStyle'] as Map<String, dynamic>),
      trendLinePattern: _patternFromJson(
          json['trendLinePattern'], defaults.trendLinePattern),
      levelsPattern:
          _patternFromJson(json['levelsPattern'], defaults.levelsPattern),
      useOneColor: json['useOneColor'] as bool? ?? defaults.useOneColor,
      fillEnabled: json['fillEnabled'] as bool? ?? defaults.fillEnabled,
      fillOpacity:
          (json['fillOpacity'] as num?)?.toDouble() ?? defaults.fillOpacity,
      extend: fibExtendModeFromJson(json['extend']),
      showLabels: json['showLabels'] as bool? ?? defaults.showLabels,
      labelMode: fibLabelModeFromJson(json['labelMode']),
    );
  }

  /// Unique name for this drawing tool.
  static const String name = 'dt_fib_retracement';

  /// JSON key of the style schema version.
  static const String styleVersionKey = 'fibStyleVersion';

  /// Current style schema version written by [toJson].
  static const int styleVersion = 2;

  /// TradingView-like default levels and palette.
  static const List<FibLevel> defaultLevels = <FibLevel>[
    FibLevel(value: 0, color: Color(0xFF787B86)),
    FibLevel(value: 0.236, color: Color(0xFFF23645)),
    FibLevel(value: 0.382, color: Color(0xFFFF9800)),
    FibLevel(value: 0.5, color: Color(0xFF4CAF50)),
    FibLevel(value: 0.618, color: Color(0xFF089981)),
    FibLevel(value: 0.786, color: Color(0xFF00BCD4)),
    FibLevel(value: 1, color: Color(0xFF787B86)),
    FibLevel(value: 1.618, color: Color(0xFF2962FF), enabled: false),
    FibLevel(value: 2.618, color: Color(0xFFF23645), enabled: false),
    FibLevel(value: 3.618, color: Color(0xFF9C27B0), enabled: false),
    FibLevel(value: 4.236, color: Color(0xFFE91E63), enabled: false),
  ];

  /// Shared level-line thickness ([LineStyle.thickness]) and the override
  /// color applied to every level when [useOneColor] is on.
  final LineStyle lineStyle;

  /// Retracement levels with per-level color and visibility.
  final List<FibLevel> levels;

  /// Whether the diagonal trend line between the anchors is drawn.
  final bool showTrendLine;

  /// Style of the trend line.
  final LineStyle trendLineStyle;

  /// Pattern of the trend line.
  final DrawingPatterns trendLinePattern;

  /// Pattern of the level lines.
  final DrawingPatterns levelsPattern;

  /// Paints every level with [lineStyle]'s color instead of per-level colors.
  final bool useOneColor;

  /// Whether translucent fills are painted between adjacent levels.
  final bool fillEnabled;

  /// Opacity of the fill between adjacent levels.
  final double fillOpacity;

  /// Horizontal extension of the level lines.
  final FibExtendMode extend;

  /// Whether level labels are drawn.
  final bool showLabels;

  /// Level label content.
  final FibLabelMode labelMode;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'number': number,
        'drawingData': drawingData?.toJson(),
        'edgePoints':
            edgePoints.map((edgePoint) => edgePoint.toJson()).toList(),
        DrawingToolConfig.configIdKey: configId,
        'lineStyle': lineStyle.toJson(),
        DrawingToolConfig.nameKey: name,
        styleVersionKey: styleVersion,
        'levels': levels.map((level) => level.toJson()).toList(),
        'showTrendLine': showTrendLine,
        'trendLineStyle': trendLineStyle.toJson(),
        'trendLinePattern': trendLinePattern.name,
        'levelsPattern': levelsPattern.name,
        'useOneColor': useOneColor,
        'fillEnabled': fillEnabled,
        'fillOpacity': fillOpacity,
        'extend': extend.name,
        'showLabels': showLabels,
        'labelMode': labelMode.name,
      };

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      FibRetracementDrawingToolItem(
        config: this,
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );

  @override
  FibRetracementDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
    List<FibLevel>? levels,
    bool? showTrendLine,
    LineStyle? trendLineStyle,
    DrawingPatterns? trendLinePattern,
    DrawingPatterns? levelsPattern,
    bool? useOneColor,
    bool? fillEnabled,
    double? fillOpacity,
    FibExtendMode? extend,
    bool? showLabels,
    FibLabelMode? labelMode,
  }) =>
      FibRetracementDrawingToolConfig(
        configId: configId ?? this.configId,
        drawingData: drawingData ?? this.drawingData,
        edgePoints: edgePoints ?? this.edgePoints,
        lineStyle: lineStyle ?? this.lineStyle,
        number: number ?? this.number,
        levels: levels ?? this.levels,
        showTrendLine: showTrendLine ?? this.showTrendLine,
        trendLineStyle: trendLineStyle ?? this.trendLineStyle,
        trendLinePattern: trendLinePattern ?? this.trendLinePattern,
        levelsPattern: levelsPattern ?? this.levelsPattern,
        useOneColor: useOneColor ?? this.useOneColor,
        fillEnabled: fillEnabled ?? this.fillEnabled,
        fillOpacity: fillOpacity ?? this.fillOpacity,
        extend: extend ?? this.extend,
        showLabels: showLabels ?? this.showLabels,
        labelMode: labelMode ?? this.labelMode,
      );

  static DrawingPatterns _patternFromJson(
          Object? value, DrawingPatterns fallback) =>
      DrawingPatterns.values
          .firstWhere((pattern) => pattern.name == value, orElse: () => fallback);
}
