import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/oscillator_lines/oscillator_lines_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/field_widget.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/oscillator_limit.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_item.dart';
import 'rsi_indicator_config.dart';

/// RSI indicator item in the list of indicator which provide this
/// indicators options menu.
class RSIIndicatorItem extends IndicatorItem {
  /// Initializes
  const RSIIndicatorItem({
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
    RSIIndicatorConfig config = const RSIIndicatorConfig(),
  }) : super(
          key: key,
          title: 'RSI',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      RSIIndicatorItemState();
}

/// RSIItem State class
class RSIIndicatorItemState extends IndicatorItemState<RSIIndicatorConfig> {
  int? _period;
  double? _overBoughtPrice;
  double? _overSoldPrice;
  String? _field;
  LineStyle? _overboughtStyle;
  LineStyle? _oversoldStyle;
  bool? _showZones;

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      );

  @override
  RSIIndicatorConfig updateIndicatorConfig() =>
      (widget.config as RSIIndicatorConfig).copyWith(
        period: _getCurrentPeriod(),
        oscillatorLinesConfig: OscillatorLinesConfig(
          overboughtValue: _getCurrentOverBoughtPrice(),
          oversoldValue: _getCurrentOverSoldPrice(),
          overboughtStyle: _currentOverboughtStyle,
          oversoldStyle: _currentOversoldStyle,
        ),
        fieldType: _getCurrentField(),
        showZones: _currentShowZones,
      );

  @override
  Widget getIndicatorOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _buildPeriodField()),
            const SizedBox(width: 12),
            Expanded(child: _buildFieldTypeMenu()),
          ],
        ),
        const SizedBox(height: 12),
        _buildOverBoughtPriceField(),
        const SizedBox(height: 12),
        _buildOverSoldPriceField(),
        const SizedBox(height: 12),
        _buildShowZonesField(),
      ],
    );
  }

  Widget _buildShowZonesField() {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Switch(
          value: _currentShowZones,
          onChanged: (bool value) {
            setState(() {
              _showZones = value;
            });
            updateIndicator();
          },
          activeColor: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            ChartLocalization.of(context).labelShowZones,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodField() => FieldWidget(
        initialValue: _getCurrentPeriod().toString(),
        label: ChartLocalization.of(context).labelPeriod,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _period = int.tryParse(text);
          } else {
            _period = 14;
          }
          updateIndicator();
        },
      );

  int _getCurrentPeriod() =>
      _period ?? (widget.config as RSIIndicatorConfig).period;

  Widget _buildFieldTypeMenu() => DropdownButtonFormField<String>(
        value: _getCurrentField(),
        decoration: _inputDecoration(ChartLocalization.of(context).labelField),
        items: IndicatorConfig.supportedFieldTypes.keys
            .map<DropdownMenuItem<String>>(
              (String fieldType) => DropdownMenuItem<String>(
                value: fieldType,
                child: Text(fieldType),
              ),
            )
            .toList(),
        onChanged: (String? newField) => setState(() {
          _field = newField;
          updateIndicator();
        }),
      );

  String _getCurrentField() =>
      _field ?? (widget.config as RSIIndicatorConfig).fieldType;

  Widget _buildOverBoughtPriceField() => OscillatorLimit(
        label: ChartLocalization.of(context).labelOverBoughtPrice,
        value: _getCurrentOverBoughtPrice(),
        color: _currentOverboughtStyle.color,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _overBoughtPrice = double.tryParse(text);
          } else {
            _overBoughtPrice = 80;
          }
          updateIndicator();
        },
        onColorChanged: (Color selectedColor) {
          setState(() {
            _overboughtStyle =
                _currentOverboughtStyle.copyWith(color: selectedColor);
          });
          updateIndicator();
        },
      );

  double _getCurrentOverBoughtPrice() =>
      _overBoughtPrice ??
      (widget.config as RSIIndicatorConfig)
          .oscillatorLinesConfig
          .overboughtValue;

  Widget _buildOverSoldPriceField() => OscillatorLimit(
        label: ChartLocalization.of(context).labelOverSoldPrice,
        value: _getCurrentOverSoldPrice(),
        color: _currentOversoldStyle.color,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _overSoldPrice = double.tryParse(text);
          } else {
            _overSoldPrice = 20;
          }
          updateIndicator();
        },
        onColorChanged: (Color selectedColor) {
          setState(() {
            _oversoldStyle =
                _currentOversoldStyle.copyWith(color: selectedColor);
          });
          updateIndicator();
        },
      );

  double _getCurrentOverSoldPrice() =>
      _overSoldPrice ??
      (widget.config as RSIIndicatorConfig).oscillatorLinesConfig.oversoldValue;

  LineStyle get _currentOverboughtStyle =>
      _overboughtStyle ??
      (widget.config as RSIIndicatorConfig)
          .oscillatorLinesConfig
          .overboughtStyle;

  LineStyle get _currentOversoldStyle =>
      _oversoldStyle ??
      (widget.config as RSIIndicatorConfig).oscillatorLinesConfig.oversoldStyle;

  bool get _currentShowZones =>
      _showZones ?? (widget.config as RSIIndicatorConfig).showZones;
}
