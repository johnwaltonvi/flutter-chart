import 'package:collection/collection.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/mobile_chart_frame_dividers.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_wrapper.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tools.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:deriv_chart/src/models/chart_axis_config.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/chart_default_light_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../add_ons/indicators_ui/adx/adx_indicator_config.dart';
import '../../add_ons/indicators_ui/alligator/alligator_indicator_config.dart';
import '../../add_ons/indicators_ui/aroon/aroon_indicator_config.dart';
import '../../add_ons/indicators_ui/awesome_oscillator/awesome_oscillator_indicator_config.dart';
import '../../add_ons/indicators_ui/bollinger_bands/bollinger_bands_indicator_config.dart';
import '../../add_ons/indicators_ui/commodity_channel_index/cci_indicator_config.dart';
import '../../add_ons/indicators_ui/donchian_channel/donchian_channel_indicator_config.dart';
import '../../add_ons/indicators_ui/dpo_indicator/dpo_indicator_config.dart';
import '../../add_ons/indicators_ui/fcb_indicator/fcb_indicator_config.dart';
import '../../add_ons/indicators_ui/gator/gator_indicator_config.dart';
import '../../add_ons/indicators_ui/ichimoku_clouds/ichimoku_cloud_indicator_config.dart';
import '../../add_ons/indicators_ui/indicator_config.dart';
import '../../add_ons/indicators_ui/ma_env_indicator/ma_env_indicator_config.dart';
import '../../add_ons/indicators_ui/ma_indicator/ma_indicator_config.dart';
import '../../add_ons/indicators_ui/macd_indicator/macd_indicator_config.dart';
import '../../add_ons/indicators_ui/parabolic_sar/parabolic_sar_indicator_config.dart';
import '../../add_ons/indicators_ui/rainbow_indicator/rainbow_indicator_config.dart';
import '../../add_ons/indicators_ui/roc/roc_indicator_config.dart';
import '../../add_ons/indicators_ui/rsi/rsi_indicator_config.dart';
import '../../add_ons/indicators_ui/smi/smi_indicator_config.dart';
import '../../add_ons/indicators_ui/stochastic_oscillator_indicator/stochastic_oscillator_indicator_config.dart';
import '../../add_ons/indicators_ui/williams_r/williams_r_indicator_config.dart';
import '../../add_ons/indicators_ui/zigzag_indicator/zigzag_indicator_config.dart';
import '../../add_ons/repository.dart';
import '../../misc/chart_controller.dart';
import '../../models/tick.dart';
import '../../theme/chart_default_dark_theme.dart';
import '../../theme/chart_theme.dart';
import '../interactive_layer/interactive_layer_behaviours/interactive_layer_behaviour.dart';
import 'bottom_chart.dart';
import 'bottom_chart_mobile.dart';
import 'data_visualization/annotations/chart_annotation.dart';
import 'data_visualization/chart_data.dart';
import 'data_visualization/chart_series/data_series.dart';
import 'data_visualization/chart_series/series.dart';
import 'data_visualization/markers/marker_series.dart';
import 'data_visualization/models/chart_object.dart';
import 'main_chart.dart';

part 'chart_state_web.dart';

part 'chart_state_mobile.dart';

const Duration _defaultDuration = Duration(milliseconds: 300);

/// Interactive chart widget.
class Chart extends StatefulWidget {
  /// Creates chart that expands to available space.
  const Chart({
    required this.mainSeries,
    required this.granularity,
    required this.crosshairVariant,
    this.timeFormat = TimeFormat.twentyFourHour,
    this.interactiveLayerBehaviour,
    this.drawingTools,
    this.pipSize = 4,
    this.controller,
    this.overlayConfigs,
    this.auxiliaryOverlaySeries,
    this.bottomConfigs = const <IndicatorConfig>[],
    this.markerSeries,
    this.theme,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
    this.onCrosshairHover,
    this.onVisibleAreaChanged,
    this.onQuoteAreaChanged,
    this.isLive = false,
    this.dataFitEnabled = false,
    this.opacity = 1.0,
    this.annotations,
    this.chartAxisConfig = const ChartAxisConfig(),
    this.showCrosshair = false,
    this.indicatorsRepo,
    this.msPerPx,
    this.minIntervalWidth,
    this.maxIntervalWidth,
    this.dataFitPadding,
    this.currentTickAnimationDuration,
    this.quoteBoundsAnimationDuration,
    this.showCurrentTickBlinkAnimation,
    this.verticalPaddingFraction,
    this.bottomChartTitleMargin,
    this.showDataFitButton,
    this.showScrollToLastTickButton,
    this.loadingAnimationColor,
    this.useDrawingToolsV2 = false,
    Key? key,
  }) : super(key: key);

  /// Whether to use new drawing tools or not.
  final bool useDrawingToolsV2;

  /// Chart's main data series.
  final DataSeries<Tick> mainSeries;

  /// List of overlay indicator series to add on chart beside the [mainSeries].
  final List<IndicatorConfig>? overlayConfigs;

  /// Non-persistent caller-owned overlays rendered beside [mainSeries].
  final List<Series>? auxiliaryOverlaySeries;

  /// List of bottom indicator series to add on chart separate from the
  /// [mainSeries].
  final List<IndicatorConfig> bottomConfigs;

  /// Open position marker series.
  final MarkerSeries? markerSeries;

  /// Keep the reference to the drawing tools class for
  /// sharing data between the DerivChart and the DrawingToolsDialog
  final DrawingTools? drawingTools;

  /// Chart's controller
  final ChartController? controller;

  /// Number of digits after decimal point in price.
  final int pipSize;

  /// For candles: Duration of one candle in ms.
  /// For ticks: Average ms difference between two consecutive ticks.
  final int granularity;

  /// Preferred time format for axis labels and crosshair.
  final TimeFormat timeFormat;

  /// Called when crosshair details appear after long press.
  final VoidCallback? onCrosshairAppeared;

  /// Called when the crosshair is dismissed.
  final VoidCallback? onCrosshairDisappeared;

  /// Called when the crosshair cursor is hovered/moved.
  final OnCrosshairHoverCallback? onCrosshairHover;

  /// Called when chart is scrolled or zoomed.
  final VisibleAreaChangedCallback? onVisibleAreaChanged;

  /// Callback provided by library user.
  final VisibleQuoteAreaChangedCallback? onQuoteAreaChanged;

  /// Chart's theme.
  final ChartTheme? theme;

  /// Chart's annotations
  final List<ChartAnnotation<ChartObject>>? annotations;

  /// Whether the chart should be showing live data or not.
  ///
  /// In case of being true the chart will keep auto-scrolling when its visible
  /// area is on the newest ticks/candles.
  final bool isLive;

  /// Starts in data fit mode and adds a data-fit button.
  final bool dataFitEnabled;

  /// Chart's opacity, Will be applied on the [mainSeries].
  final double opacity;

  /// Configurations for chart's axes.
  final ChartAxisConfig chartAxisConfig;

  /// Whether the crosshair should be shown or not.
  final bool showCrosshair;

  /// Specifies the zoom level of the chart.
  final double? msPerPx;

  /// Specifies the minimum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? minIntervalWidth;

  /// Specifies the maximum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? maxIntervalWidth;

  /// Padding around data used in data-fit mode.
  final EdgeInsets? dataFitPadding;

  /// Duration of the current tick animated transition.
  final Duration? currentTickAnimationDuration;

  /// Duration of quote bounds animated transition.
  final Duration? quoteBoundsAnimationDuration;

  /// Whether to show current tick blink animation or not.
  final bool? showCurrentTickBlinkAnimation;

  /// Fraction of the chart's height taken by top or bottom padding.
  /// Quote scaling (drag on quote area) is controlled by this variable.
  final double? verticalPaddingFraction;

  /// Specifies the margin to prevent overlap.
  final EdgeInsets? bottomChartTitleMargin;

  /// Whether the data fit button is shown or not.
  final bool? showDataFitButton;

  /// Whether to show the scroll to last tick button or not.
  final bool? showScrollToLastTickButton;

  /// The color of the loading animation.
  final Color? loadingAnimationColor;

  /// Chart's indicators
  final Repository<IndicatorConfig>? indicatorsRepo;

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

  /// The interactive layer behaviour.
  final InteractiveLayerBehaviour? interactiveLayerBehaviour;

  @override
  State<StatefulWidget> createState() =>
      // TODO(Ramin): Make this customizable from outside.
      kIsWeb ? _ChartStateWeb() : _ChartStateMobile();
}

// ignore: prefer_mixin
abstract class _ChartState extends State<Chart> with WidgetsBindingObserver {
  bool? _followCurrentTick;
  late ChartController _controller;
  late ChartTheme _chartTheme;
  late List<Series>? bottomSeries;
  int? expandedIndex;
  Repository<IndicatorConfig>? _listenedIndicatorsRepo;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addObserver(this);
    _initChartController();
    _attachIndicatorsRepo(widget.indicatorsRepo);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initChartTheme();
  }

  void _initChartController() {
    _controller = widget.controller ?? ChartController();
  }

  IndicatorInput _buildIndicatorInput() =>
      IndicatorInput(widget.mainSeries.input, widget.granularity);

  bool _canRenderIndicator(
    IndicatorConfig config, {
    IndicatorInput? indicatorInput,
  }) {
    return config.canRender(indicatorInput ?? _buildIndicatorInput());
  }

  List<IndicatorConfig> _getRenderableConfigs(
    List<IndicatorConfig>? configs, {
    IndicatorInput? indicatorInput,
  }) {
    final source = configs;
    if (source == null || source.isEmpty) {
      return const <IndicatorConfig>[];
    }

    final input = indicatorInput ?? _buildIndicatorInput();
    return source
        .where((config) => _canRenderIndicator(config, indicatorInput: input))
        .toList(growable: false);
  }

  List<IndicatorConfig> getRenderableRepositoryConfigs({
    required bool isOverlay,
    IndicatorInput? indicatorInput,
  }) {
    final repository = widget.indicatorsRepo;
    if (repository == null) {
      return const <IndicatorConfig>[];
    }

    final input = indicatorInput ?? _buildIndicatorInput();
    return repository.items
        .where(
          (config) =>
              config.isOverlay == isOverlay &&
              _canRenderIndicator(config, indicatorInput: input),
        )
        .toList(growable: false);
  }

  String formatIndicatorTitle(
    IndicatorConfig config, {
    bool includeSummary = true,
  }) {
    final suffix = config.number > 0 ? ' ${config.number}' : '';
    if (!includeSummary || config.configSummary.trim().isEmpty) {
      return '${config.shortTitle}$suffix';
    }
    return '${config.shortTitle}$suffix (${config.configSummary})';
  }

  List<Series>? _getIndicatorSeries(
    List<IndicatorConfig>? configs, {
    IndicatorInput? indicatorInput,
  }) {
    if (configs == null) {
      return null;
    }

    final input = indicatorInput ?? _buildIndicatorInput();
    final renderableConfigs = configs
        .where((config) => _canRenderIndicator(config, indicatorInput: input))
        .toList(growable: false);

    return renderableConfigs
        .map((IndicatorConfig indicatorConfig) => indicatorConfig.getSeries(
              input,
            ))
        .toList();
  }

  void _initChartTheme() {
    _chartTheme = widget.theme ??
        (Theme.of(context).brightness == Brightness.dark
            ? ChartDefaultDarkTheme()
            : ChartDefaultLightTheme());
  }

  void _attachIndicatorsRepo(Repository<IndicatorConfig>? repository) {
    if (identical(repository, _listenedIndicatorsRepo)) {
      return;
    }

    _listenedIndicatorsRepo?.removeListener(_handleIndicatorsRepoChanged);
    _listenedIndicatorsRepo = repository;
    _listenedIndicatorsRepo?.addListener(_handleIndicatorsRepoChanged);
  }

  void _handleIndicatorsRepoChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _onIndicatorHideToggleTapped(
    Repository<IndicatorConfig>? repository,
    int index,
  ) {
    if (repository == null) {
      return;
    }
    repository.updateHiddenStatus(
      index: index,
      hidden: !repository.getHiddenStatus(index),
    );
  }

  Widget _buildOverlayIndicatorsLabels() {
    final Repository<IndicatorConfig>? repository = widget.indicatorsRepo;
    if (repository == null) {
      return const SizedBox.shrink();
    }

    final indicatorInput = _buildIndicatorInput();
    final List<Widget> overlayIndicatorsLabels = <Widget>[];
    for (int i = 0; i < repository.items.length; i++) {
      final IndicatorConfig config = repository.items[i];
      if (!config.isOverlay ||
          !_canRenderIndicator(config, indicatorInput: indicatorInput)) {
        continue;
      }

      overlayIndicatorsLabels.add(
        Padding(
          padding: const EdgeInsets.only(bottom: Dimens.margin04),
          child: IndicatorLabelMobile(
            title: formatIndicatorTitle(config),
            titleColor: _resolveIndicatorLabelColor(config),
            showMoveUpIcon: false,
            showMoveDownIcon: false,
            isHidden: repository.getHiddenStatus(i),
            onEditTapped: () {
              repository.editAt(i);
            },
            onHideUnhideToggle: () {
              _onIndicatorHideToggleTapped(repository, i);
            },
          ),
        ),
      );
    }

    if (overlayIndicatorsLabels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: overlayIndicatorsLabels,
    );
  }

  Color? _resolveIndicatorLabelColor(IndicatorConfig config) {
    if (config is BollingerBandsIndicatorConfig) {
      return config.middleLineStyle.color;
    }

    if (config is MAEnvIndicatorConfig) {
      return config.middleLineStyle.color;
    }

    if (config is DonchianChannelIndicatorConfig) {
      return config.middleLineStyle.color;
    }

    if (config is AlligatorIndicatorConfig) {
      return config.jawLineStyle.color;
    }

    if (config is RainbowIndicatorConfig) {
      final styles = config.rainbowLineStyles;
      if (styles != null && styles.isNotEmpty) {
        return styles.first.color;
      }
      return null;
    }

    if (config is MAIndicatorConfig) {
      return config.lineStyle.color;
    }

    if (config is ZigZagIndicatorConfig) {
      return config.lineStyle.color;
    }

    if (config is RSIIndicatorConfig) {
      return config.lineStyle.color;
    }

    if (config is CCIIndicatorConfig) {
      return config.lineStyle.color;
    }

    if (config is ADXIndicatorConfig) {
      return config.lineStyle.color;
    }

    if (config is DPOIndicatorConfig) {
      return config.lineStyle.color;
    }

    if (config is SMIIndicatorConfig) {
      return config.lineStyle?.color;
    }

    if (config is WilliamsRIndicatorConfig) {
      return config.lineStyle.color;
    }

    if (config is StochasticOscillatorIndicatorConfig) {
      return config.lineStyle.color;
    }

    if (config is AroonIndicatorConfig) {
      return config.upLineStyle.color;
    }

    if (config is ROCIndicatorConfig) {
      return config.lineStyle?.color;
    }

    if (config is MACDIndicatorConfig) {
      return config.lineStyle.color;
    }

    if (config is IchimokuCloudIndicatorConfig) {
      return config.conversionLineStyle.color;
    }

    if (config is ParabolicSARConfig) {
      return config.scatterStyle.color;
    }

    if (config is FractalChaosBandIndicatorConfig) {
      return config.highLineStyle.color;
    }

    if (config is AwesomeOscillatorIndicatorConfig) {
      return config.barStyle.positiveColor;
    }

    if (config is GatorIndicatorConfig) {
      return config.barStyle.positiveColor;
    }

    return null;
  }

  void _onCrosshairHover(
    Offset globalPosition,
    Offset localPosition,
    EpochToX epochToX,
    QuoteToY quoteToY,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
  ) {
    widget.onCrosshairHover?.call(
      globalPosition,
      localPosition,
      epochToX,
      quoteToY,
      epochFromX,
      quoteFromY,
      null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChartConfig chartConfig = ChartConfig(
      pipSize: widget.pipSize,
      granularity: widget.granularity,
      chartAxisConfig: widget.chartAxisConfig,
      timeFormat: widget.timeFormat,
    );
    // Calculate default msPerPx based on granularity and default interval width (which defaults to 20 pixels), msPerPx could be null in situations like when data fit mode is enabled.
    final double defaultMsPerPx =
        widget.granularity / widget.chartAxisConfig.defaultIntervalWidth;

    final ChartScaleModel _chartScaleModel = ChartScaleModel(
        granularity: widget.granularity,
        msPerPx: widget.msPerPx ?? defaultMsPerPx);

    final indicatorInput = _buildIndicatorInput();
    final renderableOverlayConfigs = _getRenderableConfigs(
      widget.overlayConfigs,
      indicatorInput: indicatorInput,
    );
    final renderableBottomConfigs = _getRenderableConfigs(
      widget.bottomConfigs,
      indicatorInput: indicatorInput,
    );

    final List<Series>? overlaySeries = _getIndicatorSeries(
      renderableOverlayConfigs,
      indicatorInput: indicatorInput,
    );

    final List<Series>? bottomSeries = _getIndicatorSeries(
      renderableBottomConfigs,
      indicatorInput: indicatorInput,
    );

    final List<ChartData> chartDataList = <ChartData>[
      widget.mainSeries,
      if (overlaySeries != null) ...overlaySeries,
      if (widget.auxiliaryOverlaySeries != null)
        ...widget.auxiliaryOverlaySeries!,
      if (bottomSeries != null) ...bottomSeries,
      if (widget.annotations != null) ...widget.annotations!,
    ];

    _controller
      ..getSeriesList = (() => <Series>[
            if (overlaySeries != null) ...overlaySeries,
            if (bottomSeries != null) ...bottomSeries,
          ])
      ..getConfigsList = (() => <IndicatorConfig>[
            ...renderableOverlayConfigs,
            ...renderableBottomConfigs,
          ]);

    final Duration currentTickAnimationDuration =
        widget.currentTickAnimationDuration ?? _defaultDuration;

    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<ChartTheme>.value(value: _chartTheme),
        Provider<ChartConfig>.value(value: chartConfig),
        Provider<ChartScaleModel>.value(value: _chartScaleModel),
      ],
      child: Ink(
        color: _chartTheme.backgroundColor,
        child: GestureManager(
          child: XAxisWrapper(
            maxEpoch: chartDataList.getMaxEpoch(),
            minEpoch: chartDataList.getMinEpoch(),
            chartAxisConfig: widget.chartAxisConfig,
            entries: widget.mainSeries.input,
            pipSize: widget.pipSize,
            onVisibleAreaChanged: _onVisibleAreaChanged,
            isLive: widget.isLive,
            startWithDataFitMode: widget.dataFitEnabled,
            msPerPx: widget.msPerPx,
            minIntervalWidth: widget.minIntervalWidth,
            maxIntervalWidth: widget.maxIntervalWidth,
            dataFitPadding: widget.dataFitPadding,
            scrollAnimationDuration: currentTickAnimationDuration,
            child: buildChartsLayout(
              context,
              overlaySeries,
              bottomSeries,
              widget.auxiliaryOverlaySeries,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChartsLayout(
    BuildContext context,
    List<Series>? overlaySeries,
    List<Series>? bottomSeries,
    List<Series>? auxiliaryOverlaySeries,
  );

  void _onEdit(IndicatorConfig config) {
    if (widget.indicatorsRepo != null) {
      final int index = widget.indicatorsRepo!.items.indexOf(config);
      widget.indicatorsRepo!.editAt(index);
    }
  }

  void _onRemove(IndicatorConfig config) {
    expandedIndex = null;

    if (widget.indicatorsRepo != null) {
      final int index = widget.indicatorsRepo!.items.indexOf(config);
      widget.indicatorsRepo!.removeAt(index);
    }
  }

  void _onSwap(IndicatorConfig config1, IndicatorConfig config2) {
    if (widget.indicatorsRepo != null) {
      final int index1 = widget.indicatorsRepo!.items.indexOf(config1);
      final int index2 = widget.indicatorsRepo!.items.indexOf(config2);
      widget.indicatorsRepo!.swap(index1, index2);
    }
  }

  void _onVisibleAreaChanged(int leftBoundEpoch, int rightBoundEpoch) {
    widget.onVisibleAreaChanged?.call(leftBoundEpoch, rightBoundEpoch);

    // detect what is current viewing mode before lock the screen
    if (widget.mainSeries.entries != null &&
        widget.mainSeries.entries!.isNotEmpty) {
      if (rightBoundEpoch > widget.mainSeries.entries!.last.epoch) {
        _followCurrentTick = true;
      } else {
        _followCurrentTick = false;
      }
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    //scroll to last tick when screen is on
    if (state == AppLifecycleState.resumed &&
        _followCurrentTick != null &&
        _followCurrentTick!) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
        _controller.onScrollToLastTick?.call(animate: false);
      });
    }
  }

  @override
  void dispose() {
    _listenedIndicatorsRepo?.removeListener(_handleIndicatorsRepoChanged);
    WidgetsFlutterBinding.ensureInitialized().removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);

    // if controller is set
    if (widget.controller != oldWidget.controller) {
      _initChartController();
    }
    if (widget.theme != oldWidget.theme) {
      _initChartTheme();
    }

    if (!identical(widget.indicatorsRepo, oldWidget.indicatorsRepo)) {
      _attachIndicatorsRepo(widget.indicatorsRepo);
    }

    //check if entire entries changes(market or granularity changes)
    // scroll to last tick
    if (widget.mainSeries.entries != null &&
        widget.mainSeries.entries!.isNotEmpty) {
      if (widget.mainSeries.entries!.first.epoch !=
          oldWidget.mainSeries.entries!.first.epoch) {
        _controller.onScrollToLastTick?.call(animate: false);
      }
    }

    // Check if the the expanded bottom indicator is moved/removed.
    if (expandedIndex != null &&
        oldWidget.bottomConfigs.length != widget.bottomConfigs.length &&
        expandedIndex! < (oldWidget.bottomConfigs.length)) {
      final int? newIndex =
          widget.bottomConfigs.indexOf(oldWidget.bottomConfigs[expandedIndex!]);
      if (newIndex != expandedIndex) {
        expandedIndex = newIndex == -1 ? null : newIndex;
      }
    }
  }
}
