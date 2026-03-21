import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import 'text_drawing_tool_config.dart';

/// Text drawing tool item in the list of drawing tools.
class TextDrawingToolItem extends DrawingToolItem {
  /// Initializes [TextDrawingToolItem].
  const TextDrawingToolItem({
    required UpdateDrawingTool updateDrawingTool,
    required VoidCallback deleteDrawingTool,
    Key? key,
    TextDrawingToolConfig config = const TextDrawingToolConfig(),
  }) : super(
          key: key,
          title: 'Text',
          config: config,
          updateDrawingTool: updateDrawingTool,
          deleteDrawingTool: deleteDrawingTool,
        );

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      TextDrawingToolItemState();
}

/// State of [TextDrawingToolItem].
class TextDrawingToolItemState
    extends DrawingToolItemState<TextDrawingToolConfig> {
  late final TextEditingController _textController;
  LineStyle? _lineStyle;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _currentConfig.text);
  }

  @override
  void didUpdateWidget(covariant TextDrawingToolItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_textController.text != _currentConfig.text) {
      _textController.value = TextEditingValue(
        text: _currentConfig.text,
        selection: TextSelection.collapsed(
          offset: _currentConfig.text.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  TextDrawingToolConfig createDrawingToolConfig() => TextDrawingToolConfig(
        text: _resolvedText,
        lineStyle: _currentLineStyle,
      );

  @override
  Widget getDrawingToolOptions() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _textController,
            minLines: 1,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Text',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => updateDrawingTool(),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text(
                ChartLocalization.of(context).labelColor,
                style: const TextStyle(fontSize: 16),
              ),
              ColorSelector(
                currentColor: _currentLineStyle.color,
                onColorChanged: (Color selectedColor) {
                  setState(() {
                    _lineStyle =
                        _currentLineStyle.copyWith(color: selectedColor);
                  });
                  updateDrawingTool();
                },
              ),
            ],
          ),
        ],
      );

  TextDrawingToolConfig get _currentConfig =>
      widget.config as TextDrawingToolConfig;

  LineStyle get _currentLineStyle => _lineStyle ?? _currentConfig.lineStyle;

  String get _resolvedText {
    final trimmed = _textController.text.trim();
    return trimmed.isEmpty ? TextDrawingToolConfig.defaultText : trimmed;
  }
}
