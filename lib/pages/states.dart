import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:covid19app/data/DataFormat.dart';
import 'package:covid19app/utils/utils.dart';

class StateList extends StatefulWidget {
  @override
  _StateListState createState() => _StateListState();
}

class _StateListState extends State<StateList> {

  List<StateData> states = <StateData>[];
  List<StateWiseReport> stateWiseReports = <StateWiseReport>[];

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double heightRatio = height/896.0;
    double widthRatio = width/414.0;

    dynamic responseData = ModalRoute.of(context).settings.arguments;
    states = responseData["states"];
    stateWiseReports = responseData["stateWiseReports"];

    List<Widget> stateList = states.map((state) {
      return Padding(
        padding: EdgeInsets.fromLTRB(heightRatio*10,widthRatio*3,heightRatio*10,0),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context, state);
          },
          child: Card(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(heightRatio*20,widthRatio*10,heightRatio*20,widthRatio*5),
                  child: Row(
                    children: <Widget>[
                      Text(
                        state.state,
                        style: TextStyle(
                          fontSize: heightRatio*18,
                          color: Colors.grey[800]
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(heightRatio*20,0,heightRatio*20,widthRatio*10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        timeAgo(
                          DateTime.parse(
                            DateFormat("dd/MM/yyy HH:mm:ss").parse(
                              stateWiseReports.where((report)=>report.state==state).toList()[0].lastUpdated
                            ).toString()
                          )
                        ),
//                        stateWiseReports.where((report)=>report.state==state).toList()[0].lastUpdated,
                        style: TextStyle(
                            fontSize: heightRatio*14,
                            color: Colors.green[400]
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "States",
          style: TextStyle(
            fontSize: heightRatio*22
          ),
        ),
        backgroundColor: Colors.redAccent[200],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, widthRatio*10, 0, widthRatio*30),
        children: stateList,
      ),
    );
  }
}
