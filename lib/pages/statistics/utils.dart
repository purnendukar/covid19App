import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:covid19app/data/DataFormat.dart';

class MakeLineGraph {
  double widthRatio;
  double heightRatio;
  List  selectedReport = [];
  List<FlSpot> graphSports = <FlSpot>[];


  MakeLineGraph({@required this.widthRatio, @required this.heightRatio, @required this.selectedReport});

  LineChart buildLineChart({List<FlSpot> reportSpots, double maxYlimit,double minYlimit = 0.0, Color color}) {
    double xInterval = selectedReport.length*0.9/3;
    xInterval = xInterval.toInt().toDouble()/100000;
    double yInterval = (maxYlimit-minYlimit)*100000/5;
//    print("yInterval ${yInterval}");
    yInterval = yInterval.toInt()/100000;
    yInterval = yInterval==0 ? 1/100000:yInterval;
//    print("yInterval: "+yInterval.toString());
//    print("maxY: "+maxYlimit.toString());
//    print("minY: "+minYlimit.toString());
//    print("maxYlimit ${maxYlimit}");
    maxYlimit = maxYlimit==0 ? 1/100000:maxYlimit;
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: selectedReport.length.toDouble()/100000,
        minY: minYlimit,
        maxY: maxYlimit,
        clipToBorder: true,
        lineTouchData: LineTouchData(
          getTouchedSpotIndicator: getTouchedIndicators,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: TouchedData,
            tooltipBgColor: Colors.grey[800].withOpacity(0.9),
          ),
//          touchCallback: (LineTouchResponse touchResponse) {
//            print(touchResponse);
//          },
          handleBuiltInTouches: true,
        ),
        gridData: FlGridData(
          drawHorizontalLine: true,
          horizontalInterval: yInterval,
          drawVerticalLine: true,
          verticalInterval: xInterval,
          show: true,
        ),
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            interval: xInterval,
            showTitles: true,
            reservedSize: widthRatio*22,
            textStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: heightRatio*12,
            ),
            getTitles: (value) {
              value*=100000;
//              int deviderMark = (xInterval*100000).toInt();
//              if(value.toInt()==deviderMark){
//                return selectedReport[deviderMark].date;
//              }else if(value.toInt()==deviderMark*2){
//                return selectedReport[deviderMark*2].date;
//              }else if(value.toInt()==deviderMark*3){
//                return selectedReport[deviderMark*3].date;
//              }
              return selectedReport[value.toInt()].date;
            },
            margin: heightRatio*6,
          ),
          leftTitles: SideTitles(
            interval: yInterval,
            showTitles: true,
            textStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: heightRatio*12,
            ),
            getTitles: (value) {
//              print("$value $yInterval");
              value*=100000;
//              int deviderMark = (yInterval*100000).toInt();
//              if(value.toInt()==minYlimit){
//                return NumberFormat.compact(locale:'en_US').format(minYlimit);
//              }
//              else if(value.toInt()==deviderMark){
//                return NumberFormat.compact(locale:'en_US').format(deviderMark);
//              }else if(value.toInt()==deviderMark*2){
//                return NumberFormat.compact(locale:'en_US').format(deviderMark*2);
//              }else if(value.toInt()==deviderMark*3){
//                return NumberFormat.compact(locale:'en_US').format(deviderMark*3);
//              }else if(value.toInt()==deviderMark*4){
//                return NumberFormat.compact(locale:'en_US').format(deviderMark*4);
//              }else if(value.toInt()==deviderMark*5){
//                return NumberFormat.compact(locale:'en_US').format(deviderMark*5);
//              }
              return NumberFormat.compact(locale:'en_US').format(value);
            },
            margin: widthRatio*1,
            reservedSize: heightRatio*36,
          ),
          rightTitles: SideTitles(
//            reservedSize: heightRatio*40,
            margin: widthRatio*6,
            showTitles: true,
            getTitles: (value) {
              return "";
            }
          )
        ),
        lineBarsData: [
          LineChartBarData(
            dotData: FlDotData(
                dotSize: heightRatio*3
            ),
            isCurved: false,
            colors: [
              color
            ],
            barWidth: 1,
            spots: reportSpots,
          ),
        ],
      ),
      swapAnimationDuration: Duration(milliseconds: 600),
    );
  }

  List<TouchedSpotIndicatorData> getTouchedIndicators(
      LineChartBarData barData, List<int> indicators) {
    if (indicators == null) {
      return [];
    }
    return indicators.map((int index) {
      /// Indicator Line
      Color lineColor = barData.colors[0];
      if (barData.dotData.show) {
        lineColor = barData.dotData.getDotColor(barData.spots[index], 0, barData);
      }
      const double lineStrokeWidth = 1;
      final FlLine flLine = FlLine(color: lineColor, strokeWidth: lineStrokeWidth);

      /// Indicator dot
      double dotSize = 10;
      if (barData.dotData.show) {
        dotSize = barData.dotData.dotSize * 1.8 * widthRatio;
      }
      final dotData = FlDotData(
        dotSize: dotSize,
        getDotColor: (spot, percent, bar) => bar.colors[0],
      );

      return TouchedSpotIndicatorData(flLine, dotData);
    }).toList();
  }

  List<LineTooltipItem> TouchedData(List<LineBarSpot> touchedSpots) {
    if (touchedSpots == null) {
      return null;
    }

    return touchedSpots.map((LineBarSpot touchedSpot) {
      if (touchedSpot == null) {
        return null;
      }
      final TextStyle textStyle = TextStyle(
        color: Colors.white,
        fontSize: heightRatio*12,
      );
      String msg = (touchedSpot.y*100000).toInt().toString()+"\n"+selectedReport[(touchedSpot.x*100000).toInt()].date;
      return LineTooltipItem(msg, textStyle);
    }).toList();
  }

}

class GraphReport extends StatelessWidget {

  const GraphReport({
    Key key,
    @required this.heightRatio,
    @required this.widthRatio,
    @required this.makeLineGraph,
    @required this.Spots,
    @required this.maxY,
    @required this.minY,
    @required this.title,
    @required this.color
  }) : super(key: key);

  final double heightRatio;
  final double widthRatio;
  final MakeLineGraph makeLineGraph;
  final List<FlSpot> Spots;
  final double maxY;
  final double minY;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, heightRatio*10, 0, heightRatio*15),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: heightRatio*20,
                  color: color,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Container(
            height: heightRatio*280,
            child: makeLineGraph.buildLineChart(
                reportSpots: Spots,
                maxYlimit: maxY,
                color: color,
                minYlimit: minY
            ),
          ),
        ],
      ),
    );
  }
}