import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import 'horizontal_ray_drawing_tool_config.dart';

/// Horizontal ray drawing tool item in the list of drawing tools.
class HorizontalRayDrawingToolItem extends DrawingToolItem {
  /// Initializes [HorizontalRayDrawingToolItem].
  const HorizontalRayDrawingToolItem({
    required UpdateDrawingTool updateDrawingTool,
    required VoidCallback deleteDrawingTool,
    Key? key,
    HorizontalRayDrawingToolConfig config =
        const HorizontalRayDrawingToolConfig(),
  }) : super(
          key: key,
          title: 'Horizontal ray',
          config: config,
          updateDrawingTool: updateDrawingTool,
          deleteDrawingTool: deleteDrawingTool,
        );

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      HorizontalRayDrawingToolItemState();
}

/// State of [HorizontalRayDrawingToolItem].
class HorizontalRayDrawingToolItemState
    extends DrawingToolItemState<HorizontalRayDrawingToolConfig> {
  LineStyle? _lineStyle;

  @override
  HorizontalRayDrawingToolConfig createDrawingToolConfig() =>
      HorizontalRayDrawingToolConfig(
        lineStyle: _currentLineStyle,
      );

  @override
  Widget getDrawingToolOptions() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelColor,
            style: const TextStyle(fontSize: 16),
          ),
          ColorSelector(
            currentColor: _currentLineStyle.color,
            onColorChanged: (Color selectedColor) {
              setState(() {
                _lineStyle = _currentLineStyle.copyWith(color: selectedColor);
              });
              updateDrawingTool();
            },
          ),
        ],
      );

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as HorizontalRayDrawingToolConfig).lineStyle;
}
