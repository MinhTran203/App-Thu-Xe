import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:billiard/data/billard_helper.dart'; // Điều chỉnh đường dẫn theo dự án của bạn

class RevenueManagementScreen extends StatefulWidget {
  @override
  _RevenueManagementScreenState createState() =>
      _RevenueManagementScreenState();
}

class _RevenueManagementScreenState extends State<RevenueManagementScreen> {
  late List<charts.Series<MonthlyRevenue, String>> _seriesBarData;
  List<MonthlyRevenue> monthlyRevenues = [];

  @override
  void initState() {
    super.initState();
    _seriesBarData = [];
    _fetchDataAndSetState();
  }

  void _fetchDataAndSetState() async {
    final db = await DatabaseHelper().database;
    List<Map<String, dynamic>> invoices = await db.rawQuery('''
      SELECT 
        strftime('%Y', created_at) AS year,
        strftime('%m', created_at) AS month,
        strftime('%d', created_at) AS day,
        strftime('%H', created_at) AS hour,
        SUM(total_price) AS totalRevenue
      FROM Invoice
      GROUP BY year, month, day, hour
      ORDER BY year, month, day, hour
    ''');

    setState(() {
      monthlyRevenues = invoices
          .map((row) => MonthlyRevenue(
                '${row['year']}-${row['month']}-${row['day']} ${row['hour']}:00',
                row['totalRevenue'] as double,
              ))
          .toList();

      _seriesBarData = [
        charts.Series<MonthlyRevenue, String>(
          id: '',
          domainFn: (MonthlyRevenue revenue, _) => revenue.dateTime,
          measureFn: (MonthlyRevenue revenue, _) => revenue.revenue,
          data: monthlyRevenues,
          labelAccessorFn: (MonthlyRevenue row, _) =>
              '\$${row.revenue.toStringAsFixed(2)}',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        )
      ];
    });
  }

  void _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    if (selectedDatum.isNotEmpty) {
      final dateTime = selectedDatum.first.datum.dateTime;
      final revenue = selectedDatum.first.datum.revenue;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Detail for $dateTime'),
            content: Text('Revenue: \$${revenue.toStringAsFixed(2)}'),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doanh Thu',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Quản Lí Doanh Thu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
                SizedBox(height: 20.0),
                Expanded(
                  child: charts.BarChart(
                    _seriesBarData,
                    animate: true,
                    animationDuration: Duration(seconds: 1),
                    behaviors: [
                      charts.SeriesLegend(
                          position: charts.BehaviorPosition.end),
                      charts.SlidingViewport(),
                      charts.PanAndZoomBehavior(),
                      charts.SelectNearest(
                        eventTrigger: charts.SelectionTrigger.tapAndDrag,
                      ),
                    ],
                    selectionModels: [
                      charts.SelectionModelConfig(
                        type: charts.SelectionModelType.info,
                        changedListener: _onSelectionChanged,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MonthlyRevenue {
  final String dateTime;
  final double revenue;

  MonthlyRevenue(this.dateTime, this.revenue);
}
