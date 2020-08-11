import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:covid19app/utils/homeAppBar.dart';
import 'package:covid19app/data/DataFormat.dart';
import 'package:covid19app/utils/utils.dart';
import 'package:covid19app/utils/SideMenu.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<StateData> states = <StateData>[];
  List<StateWiseReport> stateWiseReports = <StateWiseReport>[];
  List<District> districts = <District>[];
  List<DistrictWiseReport> districtWiseReports = <DistrictWiseReport>[];
  List<CountryWiseReport> countryWiseReport = <CountryWiseReport>[];
  List<Countries> countries = <Countries>[];

  bool internetConnected = true;

  StateData selected_state;
  StateWiseReport stateReport;

  bool initial = true;
  dynamic indiaReport;
  int globalCount;

  Future<void> refreshPage() async{
    CoronaLoaderData data = CoronaLoaderData();
    await data.getData();

    states = data.states;
    stateWiseReports = data.stateWiseReports;
    districts = data.districts;
    districtWiseReports = data.districtWiseReports;
    globalCount = data.globalCount;
    indiaReport = stateWiseReports.where((data)=>data.state==states[0]).toList()[0];
    countries = data.countries;
    countryWiseReport = data.countryWiseReport;

    if (initial) {
      selected_state = states[0];
      initial = false;
    }

    setState(() {
      List<StateData> selected_state_copy = states.where((state)=>state.state==selected_state.state).toList();
      if (selected_state_copy.isNotEmpty){
        selected_state = selected_state_copy[0];
      }else{
        selected_state = states[0];
      }
//      print(stateWiseReports.where((data)=>data.state==selected_state).toList()[0]);
    });
  }

  Widget IndiaStateReport({double widthRatio, double heightRatio, dynamic numFormat}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(widthRatio*25, 0, widthRatio*25, 0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "India",
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: heightRatio*30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() async {
//                                  selected_state = states.where((data)=>data.state=="West Bengal").toList()[0];
                      dynamic stateResponse =await Navigator.pushNamed(
                          context,
                          "/states",
                          arguments: {
                            "states": states,
                            "stateWiseReports": stateWiseReports,
                          }
                      );
                      selected_state =  stateResponse == null ? selected_state: stateResponse;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: widthRatio*2.0,
                          color: Colors.grey[800],
                        ),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Flexible(
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              strutStyle: StrutStyle(
                                  fontSize: heightRatio*15
                              ),
                              text: TextSpan(
                                  text: selected_state.state,
                                  style: TextStyle(
                                      color: Colors.grey[900],
                                      fontSize: heightRatio*15
                                  )
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[900],
                          )
                        ],
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(widthRatio*10, heightRatio*3, widthRatio*10, heightRatio*3),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: heightRatio*30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: heightRatio*100,
                width: widthRatio*170,
                decoration: BoxDecoration(
                    color: Colors.redAccent[100],
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(widthRatio*12, heightRatio*15, 0, 0),
                      child: Text(
                        "Confirmed",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: heightRatio*19
                        ),
                      ),
                    ),
                    SizedBox(
                      height: heightRatio*12,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(widthRatio*12, heightRatio*10, 0, 0),
                      child: Text(
                        '${numFormat.format(stateReport.confirmed)}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: heightRatio*20
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: heightRatio*100,
                width: widthRatio*170,
                decoration: BoxDecoration(
                    color: Colors.indigoAccent[100],
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(widthRatio*12, heightRatio*15, 0, 0),
                      child: Text(
                        "Tested",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: heightRatio*19
                        ),
                      ),
                    ),
                    SizedBox(
                      height: heightRatio*12,
                    ),
                    Padding(
                      padding:  EdgeInsets.fromLTRB(widthRatio*12, heightRatio*10, 0, 0),
                      child: Text(
                        stateReport.tested == "-" ? "-":numFormat.format(int.parse(stateReport.tested)),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: heightRatio*18
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: heightRatio*10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: heightRatio*80,
                width: widthRatio*115,
                decoration: BoxDecoration(
                    color: Colors.blueAccent[100],
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(widthRatio*10, heightRatio*12, 0, 0),
                      child: Text(
                        "Active",
                        style: TextStyle(
                          fontSize: heightRatio*17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: heightRatio*2,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(widthRatio*12, heightRatio*10, 0, 0),
                      child: Text(
                        numFormat.format(stateReport.active),
                        style: TextStyle(
                          fontSize: heightRatio*18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: heightRatio*80,
                width: widthRatio*115,
                decoration: BoxDecoration(
                    color: Colors.green[200],
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(widthRatio*10, heightRatio*12, 0, 0),
                      child: Text(
                        "Recovered",
                        style: TextStyle(
                          fontSize: heightRatio*17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: heightRatio*2,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(widthRatio*12, heightRatio*10, 0, 0),
                      child: Text(
                        numFormat.format(stateReport.recovered),
                        style: TextStyle(
                          fontSize: heightRatio*18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: heightRatio*80,
                width: widthRatio*115,
                decoration: BoxDecoration(
                    color: Colors.blueGrey[200],
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, heightRatio*12, 0, 0),
                      child: Text(
                        "Deadth",
                        style: TextStyle(
                          fontSize: heightRatio*17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: heightRatio*2,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(12, heightRatio*10, 0, 0),
                      child: Text(
                        numFormat.format(stateReport.deaths),
                        style: TextStyle(
                          fontSize: heightRatio*18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void LoadData() async{
    await refreshPage().catchError((exception){
      if(exception is SocketException){
        internetConnected = false;
        print("internet connected: ${internetConnected}");
        NoInternetDialog(
          context: context,
          callback: LoadData
        );

      }else{
        ErrorLogs(
            page: "/home",
            error: exception.toString()
        );
        ErrorDialog(
          context: context,
          callback: LoadData
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
//    LoadData().then().catchError((e){
//      print(e);
//    });
    LoadData();
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double heightRatio = height/896.0;
    double widthRatio = width/414.0;

    if(initial == true){
      return CoronaLoader(
        widthRatio: widthRatio,
        heightRatio: heightRatio
      );
    }

    dynamic responseData = ModalRoute.of(context).settings.arguments;

    stateReport = stateWiseReports.where((data)=>data.state==selected_state).toList()[0];
    dynamic numFormat = NumberFormat( '###,###', 'en_US');

    return Scaffold(
      appBar: HomeAppBar(
          indiaCount: '${numFormat.format(indiaReport.confirmed)}',
          globalCount: '${numFormat.format(globalCount)}',
          heightRatio: heightRatio,
          widthRatio: widthRatio
      ),
      drawer: Drawer(
        child:SideMenu(
          currentRoute: "/home",
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: RefreshIndicator(
                onRefresh: refreshPage,
                child: ListView(
                  children: <Widget>[
                    SizedBox(
                      height: heightRatio*40,
                    ),
                    IndiaStateReport(
                      widthRatio: widthRatio,
                      heightRatio: heightRatio,
                      numFormat: numFormat
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(widthRatio*20, heightRatio*45, widthRatio*20, heightRatio*9),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(widthRatio*30)),
                        ),
                        padding: EdgeInsets.fromLTRB(0, heightRatio*15, 0, heightRatio*15),
                        onPressed: () {
                          Navigator.pushNamed(context, "/states/district", arguments: {
                            "stateDistrictData": districtWiseReports,
                            "states": states.sublist(1),
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(widthRatio*45, 0, 0, 0),
                                child: Text(
                                  "State District Wise Data",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: heightRatio*18.5
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: widthRatio*10,
                            ),
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.navigate_next,
                                color: Colors.white,
                                size: heightRatio*30,
                              ),
                            ),
                          ],
                        ),
                        color: Colors.red[300],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(widthRatio*20, heightRatio*9, widthRatio*20, heightRatio*30),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(widthRatio*30)),
                        ),
                        padding: EdgeInsets.fromLTRB(0, heightRatio*15, 0, heightRatio*15),
                        onPressed: () {
                          Navigator.pushNamed(context, "/countrywisereport", arguments: {
                            "countries":countries,
                            "countryWiseReport": countryWiseReport
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(widthRatio*45, 0, 0, 0),
                                child: Text(
                                  "Country Wise Data",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: heightRatio*18.5,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: widthRatio*10,
                            ),
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.navigate_next,
                                color: Colors.white,
                                size: heightRatio*30,
                              ),
                            ),
                          ],
                        ),
                        color: Colors.blueGrey[300],
                      ),
                    )
                  ],
                ),
              ),
          )
        ],
      ),
    );
  }
}


