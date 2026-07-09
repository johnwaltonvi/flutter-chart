import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import 'fib_retracement_drawing_tool_config.dart';

/// Fib retracement drawing tool item in the list of drawing tools.
class FibRetracementDrawingToolItem extends DrawingToolItem {
  /// Initializes [FibRetracementDrawingToolItem].
  const FibRetracementDrawingToolItem({
    required UpdateDrawingTool updateDrawingTool,
    required VoidCallback deleteDrawingTool,
    Key? key,
    FibRetracementDrawingToolConfig config =
        const FibRetracementDrawingToolConfig(),
  }) : super(
          key: key,
          title: 'Fib retracement',
          config: config,
          updateDrawingTool: updateDrawingTool,
          deleteDrawingTool: deleteDrawingTool,
        );

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      FibRetracementDrawingToolItemState();
}

/// State of [FibRetracementDrawingToolItem].
class FibRetracementDrawingToolItemState
    extends DrawingToolItemState<FibRetracementDrawingToolConfig> {
  LineStyle? _lineStyle;

  @override
  FibRetracementDrawingToolConfig createDrawingToolConfig() =>
      (widget.config as FibRetracementDrawingToolConfig).copyWith(
        lineStyle: _currentLineStyle,
        // The quick edit sets a single color for the whole drawing.
        useOneColor: true,
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
      _lineStyle ??
      (widget.config as FibRetracementDrawingToolConfig).lineStyle;
}
