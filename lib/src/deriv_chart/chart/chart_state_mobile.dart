part of 'chart.dart';

class _ChartStateMobile extends _ChartState {
  double _bottomSectionHeight = 0;

  @override
  void initState() {
    super.initState();

    _bottomSectionHeight =
        _getBottomIndicatorsSectionHeightFraction(widget.bottomConfigs.length);
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.bottomConfigs.length != widget.bottomConfigs.length) {
      _bottomSectionHeight = _getBottomIndicatorsSectionHeightFraction(
        widget.bottomConfigs.length,
      );
    }
  }

  @override
  Widget buildChartsLayout(
    BuildContext context,
    List<Series>? indicatorOverlaySeries,
    List<Series>? bottomSeries,
    List<Series>? auxiliaryOverlaySeries,
  ) {
    final Duration currentTickAnimationDuration =
        widget.currentTickAnimationDuration ?? _defaultDuration;

    final Duration quoteBoundsAnimationDuration =
        widget.quoteBoundsAnimationDuration ?? _defaultDuration;
    final indicatorInput = _buildIndicatorInput();

    List<Widget> getBottomIndicatorsList(BuildContext context) =>
        widget.indicatorsRepo!.items
            .mapIndexed((int index, IndicatorConfig config) {
          if (config.isOverlay) {
            return const SizedBox.shrink();
          }
          if (!_canRenderIndicator(config, indicatorInput: indicatorInput)) {
            return const SizedBox.shrink();
          }

          final Series series = config.getSeries(
            indicatorInput,
          );
          final Repository<IndicatorConfig>? repository = widget.indicatorsRepo;
          final renderableBottomConfigs = getRenderableRepositoryConfigs(
            isOverlay: false,
            indicatorInput: indicatorInput,
          );

          // TODO(Ramin): Use the key (type + number) once it's implemented.
          final int indexInBottomConfigs =
              referenceIndexOf(renderableBottomConfigs, config);

          final Widget bottomChart = BottomChartMobile(
            series: series,
            isHidden: repository?.getHiddenStatus(index) ?? false,
            granularity: widget.granularity,
            pipSize: config.pipSize,
            title: formatIndicatorTitle(config),
            titleColor: _resolveIndicatorLabelColor(config),
            currentTickAnimationDuration: currentTickAnimationDuration,
            quoteBoundsAnimationDuration: quoteBoundsAnimationDuration,
            bottomChartTitleMargin:
                const EdgeInsets.only(left: Dimens.margin04),
            onHideUnhideToggle: () =>
                _onIndicatorHideToggleTapped(repository, index),
            onEditTapped: () {
              repository?.editAt(index);
            },
            onSwap: (int offset) => _onSwap(
              config,
              renderableBottomConfigs[indexInBottomConfigs + offset],
            ),
            showMoveUpIcon:
                renderableBottomConfigs.length > 1 && indexInBottomConfigs != 0,
            showMoveDownIcon: renderableBottomConfigs.length > 1 &&
                indexInBottomConfigs != renderableBottomConfigs.length - 1,
            showFrame: context.read<ChartConfig>().chartAxisConfig.showFrame,
          );

          return (repository?.getHiddenStatus(index) ?? false)
              ? bottomChart
              : Expanded(
                  child: bottomChart,
                );
        }).toList();

    final List<Series> mainChartOverlaySeries = <Series>[
      if (widget.indicatorsRepo == null && indicatorOverlaySeries != null)
        ...indicatorOverlaySeries,
    ];

    if (widget.indicatorsRepo != null) {
      for (int i = 0; i < widget.indicatorsRepo!.items.length; i++) {
        final IndicatorConfig config = widget.indicatorsRepo!.items[i];
        if (widget.indicatorsRepo!.getHiddenStatus(i) ||
            !config.isOverlay ||
            !_canRenderIndicator(config, indicatorInput: indicatorInput)) {
          continue;
        }

        mainChartOverlaySeries.add(config.getSeries(indicatorInput));
      }
    }

    if (auxiliaryOverlaySeries != null) {
      mainChartOverlaySeries.addAll(auxiliaryOverlaySeries);
    }

    return LayoutBuilder(builder: (
      BuildContext context,
      BoxConstraints constraints,
    ) {
      final List<Widget> bottomIndicatorsList =
          getBottomIndicatorsList(context);
      return Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                if (context.read<ChartConfig>().chartAxisConfig.showFrame)
                  _buildMainChartFrame(context),
                MainChart(
                  drawingTools: widget.drawingTools,
                  controller: _controller,
                  mainSeries: widget.mainSeries,
                  overlaySeries: mainChartOverlaySeries,
                  annotations: widget.annotations,
                  markerSeries: widget.markerSeries,
                  pipSize: widget.pipSize,
                  onCrosshairAppeared: widget.onCrosshairAppeared,
                  onQuoteAreaChanged: widget.onQuoteAreaChanged,
                  isLive: widget.isLive,
                  showLoadingAnimationForHistoricalData: !widget.dataFitEnabled,
                  showDataFitButton:
                      widget.showDataFitButton ?? widget.dataFitEnabled,
                  showScrollToLastTickButton:
                      widget.showScrollToLastTickButton ?? true,
                  opacity: widget.opacity,
                  chartAxisConfig: widget.chartAxisConfig,
                  verticalPaddingFraction: widget.verticalPaddingFraction,
                  showCrosshair: widget.showCrosshair,
                  onCrosshairDisappeared: widget.onCrosshairDisappeared,
                  onCrosshairHover: _onCrosshairHover,
                  loadingAnimationColor: widget.loadingAnimationColor,
                  currentTickAnimationDuration: currentTickAnimationDuration,
                  quoteBoundsAnimationDuration: quoteBoundsAnimationDuration,
                  showCurrentTickBlinkAnimation:
                      widget.showCurrentTickBlinkAnimation ?? true,
                  crosshairVariant: widget.crosshairVariant,
                  interactiveLayerBehaviour: widget.interactiveLayerBehaviour,
                  useDrawingToolsV2: widget.useDrawingToolsV2,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimens.margin08,
                      horizontal: Dimens.margin04,
                    ),
                    child: _buildOverlayIndicatorsLabels(),
                  ),
                ),
              ],
            ),
          ),
          if (context.read<ChartConfig>().chartAxisConfig.showFrame &&
              bottomIndicatorsList.isNotEmpty)
            const Divider(
              height: 0.5,
              thickness: 1,
              color: Color(0xFF242828),
            ),
          if (_isAllBottomIndicatorsHidden)
            ...bottomIndicatorsList
          else
            SizedBox(
              height: _bottomSectionHeight * constraints.maxHeight,
              child: Column(children: bottomIndicatorsList),
            ),
        ],
      );
    });
  }

  Widget _buildMainChartFrame(BuildContext context) => Container(
        constraints: const BoxConstraints.expand(),
        child: MobileChartFrameDividers(
          color: const Color(0xFF242828),
          rightPadding: (context.read<XAxisModel>().rightPadding ?? 0) +
              _chartTheme.gridStyle.labelHorizontalPadding,
        ),
      );

  int referenceIndexOf(List<dynamic> list, dynamic element) {
    for (int i = 0; i < list.length; i++) {
      if (identical(list[i], element)) {
        return i;
      }
    }
    return -1;
  }

  double _getBottomIndicatorsSectionHeightFraction(int bottomIndicatorsCount) =>
      1 - (0.65 - 0.125 * (bottomIndicatorsCount - 1));

  bool get _isAllBottomIndicatorsHidden {
    bool isAllHidden = true;
    for (int i = 0; i < widget.indicatorsRepo!.items.length; i++) {
      if (!widget.indicatorsRepo!.items[i].isOverlay &&
          !(widget.indicatorsRepo?.getHiddenStatus(i) ?? false)) {
        isAllHidden = false;
      }
    }
    return isAllHidden;
  }
}
