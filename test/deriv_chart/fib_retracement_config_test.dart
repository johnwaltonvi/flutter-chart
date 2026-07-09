import 'package:deriv_chart/src/add_ons/drawing_tools_ui/fib_retracement/fib_level.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/fib_retracement/fib_retracement_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FibRetracementDrawingToolConfig', () {
    const customConfig = FibRetracementDrawingToolConfig(
      configId: 'fib-1',
      edgePoints: <EdgePoint>[
        EdgePoint(epoch: 100, quote: 1.5),
        EdgePoint(epoch: 200, quote: 2.5),
      ],
      lineStyle: LineStyle(color: Color(0xFFABCDEF), thickness: 3),
      levels: <FibLevel>[
        FibLevel(value: 0, color: Color(0xFF111111)),
        FibLevel(value: 0.42, color: Color(0xFF222222), enabled: false),
        FibLevel(value: 1.5, color: Color(0xFF333333)),
      ],
      showTrendLine: false,
      trendLineStyle: LineStyle(color: Color(0xFF444444), thickness: 2),
      trendLinePattern: DrawingPatterns.dotted,
      levelsPattern: DrawingPatterns.dashed,
      useOneColor: true,
      fillEnabled: false,
      fillOpacity: 0.33,
      extend: FibExtendMode.both,
      showLabels: false,
      labelMode: FibLabelMode.percentPrice,
      number: 7,
    );

    test('toJson -> fromJson round-trips every style field', () {
      final restored =
          FibRetracementDrawingToolConfig.fromJson(customConfig.toJson());

      expect(restored.configId, 'fib-1');
      expect(restored.edgePoints.length, 2);
      expect(restored.lineStyle.color, const Color(0xFFABCDEF));
      expect(restored.lineStyle.thickness, 3);
      expect(restored.levels, customConfig.levels);
      expect(restored.showTrendLine, isFalse);
      expect(restored.trendLineStyle.color, const Color(0xFF444444));
      expect(restored.trendLinePattern, DrawingPatterns.dotted);
      expect(restored.levelsPattern, DrawingPatterns.dashed);
      expect(restored.useOneColor, isTrue);
      expect(restored.fillEnabled, isFalse);
      expect(restored.fillOpacity, 0.33);
      expect(restored.extend, FibExtendMode.both);
      expect(restored.showLabels, isFalse);
      expect(restored.labelMode, FibLabelMode.percentPrice);
      expect(restored.number, 7);
    });

    test('legacy JSON (no fibStyleVersion) keeps identity, adopts defaults',
        () {
      final legacyJson = <String, dynamic>{
        'name': FibRetracementDrawingToolConfig.name,
        'configId': 'legacy-1',
        'number': 3,
        'edgePoints': <Map<String, dynamic>>[
          const EdgePoint(epoch: 10, quote: 1).toJson(),
          const EdgePoint(epoch: 20, quote: 2).toJson(),
        ],
        'lineStyle':
            const LineStyle(color: Color(0xFF0000FF), thickness: 2).toJson(),
      };

      final restored = FibRetracementDrawingToolConfig.fromJson(legacyJson);
      const defaults = FibRetracementDrawingToolConfig();

      expect(restored.configId, 'legacy-1');
      expect(restored.number, 3);
      expect(restored.edgePoints.length, 2);
      // Legacy drawings upgrade to the current default palette.
      expect(restored.levels, FibRetracementDrawingToolConfig.defaultLevels);
      expect(restored.useOneColor, defaults.useOneColor);
      expect(restored.showTrendLine, defaults.showTrendLine);
      expect(restored.fillEnabled, defaults.fillEnabled);
      expect(restored.lineStyle.color, defaults.lineStyle.color);
    });

    test('copyWith(edgePoints) preserves every style field', () {
      final moved = customConfig.copyWith(
        edgePoints: const <EdgePoint>[
          EdgePoint(epoch: 300, quote: 3),
          EdgePoint(epoch: 400, quote: 4),
        ],
      );

      expect(moved.edgePoints.first.epoch, 300);
      expect(moved.levels, customConfig.levels);
      expect(moved.showTrendLine, customConfig.showTrendLine);
      expect(moved.trendLinePattern, customConfig.trendLinePattern);
      expect(moved.levelsPattern, customConfig.levelsPattern);
      expect(moved.useOneColor, customConfig.useOneColor);
      expect(moved.fillEnabled, customConfig.fillEnabled);
      expect(moved.fillOpacity, customConfig.fillOpacity);
      expect(moved.extend, customConfig.extend);
      expect(moved.showLabels, customConfig.showLabels);
      expect(moved.labelMode, customConfig.labelMode);
      expect(moved.lineStyle.color, customConfig.lineStyle.color);
    });

    test('copyWith(configId/drawingData) preserves style (add flow)', () {
      final added = customConfig.copyWith(configId: 'new-id');

      expect(added.configId, 'new-id');
      expect(added.levels, customConfig.levels);
      expect(added.extend, customConfig.extend);
      expect(added.labelMode, customConfig.labelMode);
    });

    test('unknown enum strings fall back to defaults', () {
      final json = customConfig.toJson()
        ..['extend'] = 'sideways'
        ..['labelMode'] = 'emoji'
        ..['levelsPattern'] = 'zigzag'
        ..['trendLinePattern'] = 42;

      final restored = FibRetracementDrawingToolConfig.fromJson(json);

      expect(restored.extend, FibExtendMode.none);
      expect(restored.labelMode, FibLabelMode.percent);
      expect(restored.levelsPattern, DrawingPatterns.solid);
      expect(restored.trendLinePattern, DrawingPatterns.dashed);
    });

    test('version-2 JSON with missing style keys falls back per field', () {
      final json = customConfig.toJson()
        ..remove('levels')
        ..remove('fillOpacity')
        ..remove('trendLineStyle');

      final restored = FibRetracementDrawingToolConfig.fromJson(json);
      const defaults = FibRetracementDrawingToolConfig();

      expect(restored.levels, FibRetracementDrawingToolConfig.defaultLevels);
      expect(restored.fillOpacity, defaults.fillOpacity);
      expect(restored.trendLineStyle.color, defaults.trendLineStyle.color);
      // Fields that ARE present still parse.
      expect(restored.extend, FibExtendMode.both);
      expect(restored.useOneColor, isTrue);
    });
  });
}
