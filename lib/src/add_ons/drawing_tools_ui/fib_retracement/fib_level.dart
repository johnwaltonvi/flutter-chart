import 'package:flutter/material.dart';

/// A single Fibonacci retracement level with its own style.
@immutable
class FibLevel {
  /// Initializes [FibLevel].
  const FibLevel({
    required this.value,
    required this.color,
    this.enabled = true,
  });

  /// Initializes from JSON, falling back to [fallback] on malformed input.
  factory FibLevel.fromJson(Map<String, dynamic> json) => FibLevel(
        value: (json['value'] as num?)?.toDouble() ?? 0,
        color: Color((json['color'] as num?)?.toInt() ?? 0xFF787B86),
        enabled: json['enabled'] as bool? ?? true,
      );

  /// Ratio of the level (e.g. 0.618). Values above 1 are extensions.
  final double value;

  /// Line and label color of the level.
  final Color color;

  /// Whether the level is drawn.
  final bool enabled;

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'value': value,
        'color': color.toARGB32(),
        'enabled': enabled,
      };

  /// Creates a copy with the given fields replaced.
  FibLevel copyWith({double? value, Color? color, bool? enabled}) => FibLevel(
        value: value ?? this.value,
        color: color ?? this.color,
        enabled: enabled ?? this.enabled,
      );

  @override
  bool operator ==(Object other) =>
      other is FibLevel &&
      other.value == value &&
      other.color == color &&
      other.enabled == enabled;

  @override
  int get hashCode => Object.hash(value, color, enabled);
}

/// How Fibonacci level labels are rendered.
enum FibLabelMode {
  /// Percent only, e.g. `61.8%`.
  percent,

  /// Percent and price, e.g. `61.8% (1234.5)`.
  percentPrice,
}

/// How Fibonacci level lines extend horizontally.
enum FibExtendMode {
  /// Lines span only the two anchor points.
  none,

  /// Lines extend to the left chart edge.
  left,

  /// Lines extend to the right chart edge.
  right,

  /// Lines extend across the full chart width.
  both,
}

/// Parses [FibLabelMode] from its JSON name, defaulting to
/// [FibLabelMode.percent] for unknown input.
FibLabelMode fibLabelModeFromJson(Object? value) => FibLabelMode.values
    .firstWhere((mode) => mode.name == value, orElse: () => FibLabelMode.percent);

/// Parses [FibExtendMode] from its JSON name, defaulting to
/// [FibExtendMode.none] for unknown input.
FibExtendMode fibExtendModeFromJson(Object? value) => FibExtendMode.values
    .firstWhere((mode) => mode.name == value, orElse: () => FibExtendMode.none);
