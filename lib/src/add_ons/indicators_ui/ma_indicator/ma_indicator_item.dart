import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/field_widget.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_item.dart';
import 'ma_indicator_config.dart';

/// Moving Average indicator item in the list of indicator which provide this
/// indicator's options menu.
class MAIndicatorItem extends IndicatorItem {
  /// Initializes
  const MAIndicatorItem({
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
    MAIndicatorConfig config = const MAIndicatorConfig(),
  }) : super(
          key: key,
          title: 'Moving Average',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      MAIndicatorItemState();
}

/// MAIndicatorItem State class
class MAIndicatorItemState extends IndicatorItemState<MAIndicatorConfig> {
  /// MA type
  @protected
  MovingAverageType? type;

  /// Field type
  @protected
  String? field;

  /// MA period
  @protected
  int? period;

  /// MA period
  @protected
  int? offset;

  /// MA line style
  @protected
  LineStyle? lineStyle;

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
  MAIndicatorConfig updateIndicatorConfig() =>
      (widget.config as MAIndicatorConfig).copyWith(
        period: getCurrentPeriod(),
        movingAverageType: getCurrentType(),
        fieldType: getCurrentField(),
        offset: currentOffset,
        lineStyle: getCurrentLineStyle(),
      );

  @override
  Widget getIndicatorOptions() {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              ChartLocalization.of(context).labelColor,
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(width: 12),
            ColorSelector(
              currentColor: getCurrentLineStyle().color,
              onColorChanged: (Color selectedColor) {
                setState(() {
                  lineStyle =
                      getCurrentLineStyle().copyWith(color: selectedColor);
                });
                updateIndicator();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(child: buildMATypeMenu()),
            const SizedBox(width: 12),
            Expanded(child: buildFieldTypeMenu()),
          ],
        ),
        const SizedBox(height: 12),
        buildPeriodField(),
        const SizedBox(height: 12),
        buildOffsetField(),
      ],
    );
  }

  /// Builds MA Field type menu
  @protected
  Widget buildFieldTypeMenu() => DropdownButtonFormField<String>(
        value: getCurrentField(),
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
          field = newField;
          updateIndicator();
        }),
      );

  /// Builds Period TextFiled
  @protected
  Widget buildPeriodField() => FieldWidget(
        label: ChartLocalization.of(context).labelPeriod,
        initialValue: getCurrentPeriod().toString(),
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            period = int.tryParse(text);
          } else {
            period = 15;
          }
          updateIndicator();
        },
      );

  /// Builds offset TextFiled
  @protected
  Widget buildOffsetField() {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              ChartLocalization.of(context).labelOffset,
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(width: 8),
            Text(
              '$currentOffset',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          value: currentOffset.toDouble(),
          onChanged: (double value) {
            setState(() {
              offset = value.toInt();
              updateIndicator();
            });
          },
          divisions: 100,
          max: 100,
          label: '$currentOffset',
        ),
      ],
    );
  }

  /// Returns MA types dropdown menu
  @protected
  Widget buildMATypeMenu() => DropdownButtonFormField<MovingAverageType>(
        value: getCurrentType(),
        decoration: _inputDecoration(ChartLocalization.of(context).labelType),
        items: MovingAverageType.values
            .map<DropdownMenuItem<MovingAverageType>>(
              (MovingAverageType type) =>
                  DropdownMenuItem<MovingAverageType>(
                value: type,
                child: Text(type.title),
              ),
            )
            .toList(),
        onChanged: (MovingAverageType? newType) => setState(() {
          type = newType;
          updateIndicator();
        }),
      );

  /// Gets Indicator current type.
  @protected
  MovingAverageType getCurrentType() =>
      type ?? (widget.config as MAIndicatorConfig).movingAverageType;

  /// Gets Indicator current filed type.
  @protected
  String getCurrentField() =>
      field ?? (widget.config as MAIndicatorConfig).fieldType;

  /// Gets Indicator current period.
  @protected
  int getCurrentPeriod() =>
      period ?? (widget.config as MAIndicatorConfig).period;

  /// Gets Indicator current period.
  @protected
  int get currentOffset =>
      offset ?? (widget.config as MAIndicatorConfig).offset;

  /// Gets Indicator current line style.
  @protected
  LineStyle getCurrentLineStyle() =>
      lineStyle ?? (widget.config as MAIndicatorConfig).lineStyle;
}
