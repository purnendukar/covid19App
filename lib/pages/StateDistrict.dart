import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:covid19app/utils/utils.dart';
import 'package:covid19app/data/DataFormat.dart';

class StateDistrictExpand {
  bool isExpanded;
  StateData state;
  List<DistrictWiseReport> report;
  StateDistrictExpand({@required this.state, @required this.report, this.isExpanded=false});
}

class StateDistrictWise extends StatefulWidget {
  @override
  _StateDistrictWiseState createState() => _StateDistrictWiseState();
}

class _StateDistrictWiseState extends State<StateDistrictWise> {

  List<DistrictWiseReport> districtWiseReports = <DistrictWiseReport>[];
  List<StateData> states = <StateData>[];
  List<ExpansionPanel> reports = <ExpansionPanel>[];
  int selectedIndex;
  bool initial = true;

  List<StateDistrictExpand> stateDistrictExpand = <StateDistrictExpand>[];

  dynamic numFormat = NumberFormat( '###,###', 'en_US');

  void onClicked(int i, bool isExpand){
//    print("clied"+i.toString());
//    if(selectedIndex!=null && selectedIndex!=i){
//      stateDistrictExpand[i].isExpanded = !isExpand;
//      stateDistrictExpand[selectedIndex].isExpanded = isExpand;
//    }else{
//      stateDistrictExpand[i].isExpanded = !isExpand;
//    }
//    selectedIndex = i;
    setState(() {
    });
  }


  List stateDistictList({List<DistrictWiseReport> stateReport, double widthRatio, double heightRatio}){
    return stateReport.map((data) => Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.fromLTRB(widthRatio*20, heightRatio*5, widthRatio*10, heightRatio*5),
            child: Text(
              data.district.district,
              style: TextStyle(
                fontSize: heightRatio*16
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.fromLTRB(widthRatio*10, heightRatio*5, widthRatio*10, heightRatio*5),
            child: Text(
              numFormat.format(data.confirmed),
              style: TextStyle(
                  fontSize: heightRatio*16
              ),
            ),
          ),
        )
      ],
    )).toList();
  }

  void StateDistrictReport({double widthRatio, double heightRatio}){
    reports = stateDistrictExpand.map((stateReport) {
      return ExpansionPanelRadio(
        value: stateReport,
//        isExpanded: stateReport.isExpanded,
        headerBuilder: (BuildContext, bool isExpanded) {
          return Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(widthRatio*25, 0, 0, 0),
                child: Text(
                  stateReport.state.state,
                  style: TextStyle(
                    fontSize: heightRatio*18,
                  ),
                ),
              ),
            ],
          );
        },
        body: Container(
          padding: EdgeInsets.fromLTRB(widthRatio*20, 0, 0, heightRatio*20),
          child: Column(
            children: stateDistictList(
              stateReport: stateReport.report,
              widthRatio: widthRatio,
              heightRatio: heightRatio
            ),
          ),
        ),
        canTapOnHeader: true,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    dynamic response = ModalRoute.of(context).settings.arguments;
    districtWiseReports = response["stateDistrictData"];
    states = response["states"];

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double heightRatio = height/896.0;
    double widthRatio = width/414.0;

    if(initial){
      stateDistrictExpand = states.map((state) => StateDistrictExpand(
        state: state,
        report: districtWiseReports.where((data)=>data.state==state).toList()
      )).toList();
      initial = false;
    }

    StateDistrictReport(
        widthRatio: widthRatio,
        heightRatio: heightRatio
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "State District Report",
          style: TextStyle(
            fontSize: heightRatio*22,
          ),
        ),
        backgroundColor: Colors.redAccent[200],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(widthRatio*20, heightRatio*20, widthRatio*20, heightRatio*40),
          child: ExpansionPanelList.radio(
            children: reports,
            expansionCallback: onClicked,
            animationDuration: Duration(milliseconds: 1000),
            initialOpenPanelValue: districtWiseReports[0],
          ),
        ),
      )
    );
  }
}
