// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartConfig _$ChartConfigFromJson(Map<String, dynamic> json) => ChartConfig(
      granularity: json['granularity'] as int,
      pipSize: json['pipSize'] as int? ?? 4,
      snapMarkersToIntervals:
          json['snapMarkersToIntervals'] as bool? ?? true,
      timeFormat:
          $enumDecodeNullable(_$TimeFormatEnumMap, json['timeFormat']) ??
              TimeFormat.twentyFourHour,
    );

Map<String, dynamic> _$ChartConfigToJson(ChartConfig instance) =>
    <String, dynamic>{
      'pipSize': instance.pipSize,
      'granularity': instance.granularity,
      'snapMarkersToIntervals': instance.snapMarkersToIntervals,
      'timeFormat': _$TimeFormatEnumMap[instance.timeFormat]!,
    };

const _$TimeFormatEnumMap = {
  TimeFormat.twentyFourHour: 'twenty_four_hour',
  TimeFormat.twelveHour: 'twelve_hour',
};
