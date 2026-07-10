part of 'chart.dart';

class _ChartStateWeb extends _ChartState {
  @override
  Widget buildChartsLayout(
    BuildContext context,
    List<Series>? overlaySeries,
    List<Series>? bottomSeries,
    List<Series>? auxiliaryOverlaySeries,
  ) {
    final Duration currentTickAnimationDuration =
        widget.currentTickAnimationDuration ?? _defaultDuration;

    final Duration quoteBoundsAnimationDuration =
        widget.quoteBoundsAnimationDuration ?? _defaultDuration;

    final bool isExpanded = expandedIndex != null;
    final indicatorInput = _buildIndicatorInput();

    final List<Series>? resolvedOverlaySeries;
    if (widget.indicatorsRepo == null) {
      resolvedOverlaySeries = overlaySeries;
    } else {
      final List<Series> series = <Series>[];
      for (final config in getRenderableRepositoryConfigs(
        isOverlay: true,
        indicatorInput: indicatorInput,
      )) {
        final repositoryIndex = widget.indicatorsRepo!.items.indexOf(config);
        if (repositoryIndex == -1 ||
            widget.indicatorsRepo!.getHiddenStatus(repositoryIndex) ||
            !config.isOverlay) {
          continue;
        }
        series.add(
          config.getSeries(
            indicatorInput,
          ),
        );
      }
      resolvedOverlaySeries = series;
    }

    final List<Series> mainChartOverlaySeries = <Series>[
      if (resolvedOverlaySeries != null) ...resolvedOverlaySeries,
      if (auxiliaryOverlaySeries != null) ...auxiliaryOverlaySeries,
    ];

    final renderableBottomConfigs = _getRenderableConfigs(
      widget.bottomConfigs,
      indicatorInput: indicatorInput,
    );

    return Column(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Stack(
            children: <Widget>[
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
        if (bottomSeries?.isNotEmpty ?? false)
          ...bottomSeries!.mapIndexed((int index, Series series) {
            if (isExpanded && expandedIndex != index) {
              return const SizedBox.shrink();
            }

            return Expanded(
              flex: isExpanded ? bottomSeries.length : 1,
              child: BottomChart(
                series: series,
                granularity: widget.granularity,
                pipSize: renderableBottomConfigs[index].pipSize,
                title: renderableBottomConfigs[index].title,
                currentTickAnimationDuration: currentTickAnimationDuration,
                quoteBoundsAnimationDuration: quoteBoundsAnimationDuration,
                bottomChartTitleMargin: widget.bottomChartTitleMargin,
                onRemove: () => _onRemove(renderableBottomConfigs[index]),
                onEdit: () => _onEdit(renderableBottomConfigs[index]),
                onExpandToggle: () {
                  setState(() {
                    expandedIndex = expandedIndex != index ? index : null;
                  });
                },
                onSwap: (int offset) => _onSwap(
                  renderableBottomConfigs[index],
                  renderableBottomConfigs[index + offset],
                ),
                onCrosshairDisappeared: widget.onCrosshairDisappeared,
                onCrosshairHover: (
                  Offset globalPosition,
                  Offset localPosition,
                  EpochToX epochToX,
                  QuoteToY quoteToY,
                  EpochFromX epochFromX,
                  QuoteFromY quoteFromY,
                ) =>
                    widget.onCrosshairHover?.call(
                  globalPosition,
                  localPosition,
                  epochToX,
                  quoteToY,
                  epochFromX,
                  quoteFromY,
                  renderableBottomConfigs[index],
                ),
                isExpanded: isExpanded,
                showCrosshair: widget.showCrosshair,
                showExpandedIcon: bottomSeries.length > 1,
                showMoveUpIcon:
                    !isExpanded && bottomSeries.length > 1 && index != 0,
                showMoveDownIcon: !isExpanded &&
                    bottomSeries.length > 1 &&
                    index != bottomSeries.length - 1,
              ),
            );
          }).toList()
      ],
    );
  }
}
