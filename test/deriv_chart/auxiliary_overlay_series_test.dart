import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/main_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'auxiliary overlays extend bounds without becoming controller indicators',
    (WidgetTester tester) async {
      final ChartController controller = ChartController();
      final LineSeries mainSeries = LineSeries(
        const <Tick>[
          Tick(epoch: 100, quote: 10),
          Tick(epoch: 200, quote: 20),
        ],
        id: 'main',
      );
      final LineSeries auxiliarySeries = LineSeries(
        const <Tick>[
          Tick(epoch: 300, quote: 30),
          Tick(epoch: 400, quote: 40),
        ],
        id: 'auxiliary',
      );

      await tester.pumpWidget(
        _chart(
          mainSeries: mainSeries,
          auxiliaryOverlaySeries: <Series>[auxiliarySeries],
          controller: controller,
        ),
      );
      await tester.pump();

      final MainChart mainChart = tester.widget<MainChart>(
        find.byType(MainChart),
      );
      final XAxisWrapper xAxis = tester.widget<XAxisWrapper>(
        find.byType(XAxisWrapper),
      );

      expect(mainChart.mainSeries, same(mainSeries));
      expect(mainChart.overlaySeries, contains(same(auxiliarySeries)));
      expect(xAxis.maxEpoch, 400);
      expect(
        controller.getSeriesList?.call(),
        isEmpty,
        reason: 'auxiliary overlays are not persisted indicator series',
      );
      expect(controller.getConfigsList?.call(), isEmpty);
    },
  );

  testWidgets('updating and removing auxiliary overlays invalidates bounds', (
    WidgetTester tester,
  ) async {
    final LineSeries mainSeries = LineSeries(
      const <Tick>[
        Tick(epoch: 100, quote: 10),
        Tick(epoch: 200, quote: 20),
      ],
      id: 'main',
    );
    final LineSeries firstAuxiliary = LineSeries(
      const <Tick>[Tick(epoch: 300, quote: 30)],
      id: 'first-auxiliary',
    );
    final LineSeries replacementAuxiliary = LineSeries(
      const <Tick>[Tick(epoch: 500, quote: 50)],
      id: 'replacement-auxiliary',
    );

    await tester.pumpWidget(
      _chart(
        mainSeries: mainSeries,
        auxiliaryOverlaySeries: <Series>[firstAuxiliary],
      ),
    );
    await tester.pump();
    expect(
      tester.widget<XAxisWrapper>(find.byType(XAxisWrapper)).maxEpoch,
      300,
    );

    await tester.pumpWidget(
      _chart(
        mainSeries: mainSeries,
        auxiliaryOverlaySeries: <Series>[replacementAuxiliary],
      ),
    );
    await tester.pump();
    expect(
      tester.widget<XAxisWrapper>(find.byType(XAxisWrapper)).maxEpoch,
      500,
    );

    await tester.pumpWidget(_chart(mainSeries: mainSeries));
    await tester.pump();

    final MainChart mainChart = tester.widget<MainChart>(
      find.byType(MainChart),
    );
    expect(mainChart.overlaySeries, isEmpty);
    expect(
      tester.widget<XAxisWrapper>(find.byType(XAxisWrapper)).maxEpoch,
      200,
    );
  });
}

Widget _chart({
  required DataSeries<Tick> mainSeries,
  List<Series>? auxiliaryOverlaySeries,
  ChartController? controller,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 800,
        height: 500,
        child: DerivChart(
          mainSeries: mainSeries,
          auxiliaryOverlaySeries: auxiliaryOverlaySeries,
          granularity: 100,
          activeSymbol: 'TEST',
          controller: controller,
          showCrosshair: false,
          showDataFitButton: false,
          showScrollToLastTickButton: false,
        ),
      ),
    ),
  );
}
