import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


import 'package:covid19app/data/DataFormat.dart';
import 'package:covid19app/utils/utils.dart';
import 'package:covid19app/utils/SideMenu.dart';
import 'package:covid19app/pages/statistics/utils.dart';

class StateWiseStats extends StatefulWidget {
  @override
  _StateWiseStatsState createState() => _StateWiseStatsState();
}

class _StateWiseStatsState extends State<StateWiseStats> {

  static final statesUrl = Domains().covidIndiaDomain+"/data.json";
  static final statesDailyUrl = Domains().covidIndiaDomain+"/states_daily.json";

  List<StateData> statesData = <StateData>[];
  List<StateWiseReport> stateWiseReport = <StateWiseReport>[];
  List<StatesDailyReport> statesDailyReport = <StatesDailyReport>[];
  StateData selected_state;
  List<StatesDailyReport>  selectedReport = <StatesDailyReport>[];
  List<FlSpot> confirmedSpots = <FlSpot>[];
  List<FlSpot> activeSpots = <FlSpot>[];
  List<FlSpot> recoveredSpots = <FlSpot>[];
  List<FlSpot> deathSpots = <FlSpot>[];
  double confirmedmaxY = 0;
  double activemaxY = 0;
  double activeminY = 0;
  double recoveredmaxY = 0;
  double deathmaxY = 0;
  bool daily = false;

  List graphData = [];

  bool loader = true;

  Future<void> getData() async{
    dynamic response;
    Map responseData;

    response = await http.get(statesUrl);
    responseData = jsonDecode(response.body);

    stateWiseReport = responseData["statewise"].map<StateWiseReport>((data) {
      statesData.add(
          StateData(
              state: data["state"],
              stateCode: data["statecode"]
          )
      );
      return StateWiseReport(
          state: statesData.last,
          confirmed: int.parse(data["confirmed"]),
          recovered: int.parse(data["recovered"]),
          active: int.parse(data["active"]),
          deaths: int.parse(data["deaths"])
      );
    }).toList();

    print(stateWiseReport);

    response = await http.get(statesDailyUrl);
    responseData = jsonDecode(response.body);

    responseData["states_daily"].map((data) {
      statesData.map((state) {
        if(statesDailyReport.where((report)=>(report.state==state && report.date==data["date"])).toList().isEmpty){
          statesDailyReport.add(
              StatesDailyReport(
                date: data["date"],
                state: state,
                confirmed: data["status"]=="Confirmed"? int.parse(data[state.stateCode.toLowerCase()]==""?"0":data[state.stateCode.toLowerCase()]): 0,
                recovered: data["status"]=="Recovered"? int.parse(data[state.stateCode.toLowerCase()]==""?"0":data[state.stateCode.toLowerCase()]): 0,
                death: data["status"]=="Deceased"? int.parse(data[state.stateCode.toLowerCase()]==""?"0":data[state.stateCode.toLowerCase()]): 0,
              )
          );
        }else{
          int index = statesDailyReport.indexWhere((report)=>(report.state==state && report.date==data["date"]));
          statesDailyReport[index].confirmed = data["status"]=="Confirmed" ? int.parse(data[state.stateCode.toLowerCase()]==""?"0":data[state.stateCode.toLowerCase()]) : statesDailyReport[index].confirmed;
          statesDailyReport[index].recovered = data["status"]=="Recovered" ? int.parse(data[state.stateCode.toLowerCase()]==""?"0":data[state.stateCode.toLowerCase()]) : statesDailyReport[index].recovered;
          statesDailyReport[index].death = data["status"]=="Deceased" ? int.parse(data[state.stateCode.toLowerCase()]==""?"0":data[state.stateCode.toLowerCase()]) : statesDailyReport[index].death;
        }
      }).toList();
    }).toList();

    for(int i=0; i<statesDailyReport.length; i++){
      statesDailyReport[i].calcActive();
    }

    setState(() {
      selected_state = statesData[0];
      loadGraphData();
      loader=false;
    });

  }

  void LoadData() async {

    await getData().catchError((exception){
      if(exception is SocketException){
        NoInternetDialog(
            context: context,
            callback: LoadData
        );

      }else{
        ErrorLogs(
            page: "/stats/state_wise",
            error: exception.toString()
        );
        ErrorDialog(
          context: context,
          callback: LoadData
        );
      }
    });

  }

  void ConfirmedGraph(){
    confirmedSpots = [];
    double count = 0;
    for(int i=0; i<selectedReport.length;i++){
      count += selectedReport[i].confirmed.toDouble();
      confirmedSpots.add(
          FlSpot(i.toDouble()/100000,daily ? selectedReport[i].confirmed.toDouble()/100000:count/100000)
      );
    }
    List temp = List.from(selectedReport);
    temp.sort((a,b)=>a.confirmed.compareTo(b.confirmed));
    confirmedmaxY = daily? temp.last.confirmed*1.1:count*1.1;
    confirmedmaxY/=100000;
  }
  void ActiveGraph(){
    activeSpots = [];
    double count = 0;
    double temp_count = 0;
    for(int i=0; i<selectedReport.length;i++){
      temp_count += selectedReport[i].active.toDouble();
      count = count<temp_count? temp_count:count;
      activeSpots.add(
          FlSpot(i.toDouble()/100000, daily? selectedReport[i].active.toDouble()/100000: temp_count/100000)
      );
    }
    List temp = List.from(selectedReport);
    temp.sort((a,b)=>a.active.compareTo(b.active));
    activemaxY = daily? temp.last.active*1.1: count*1.1;
    activemaxY/=100000;
    activeminY = temp.first.active/100000;
  }
  void RecoveredGraph(){
    recoveredSpots = [];
    double count = 0;
    for(int i=0; i<selectedReport.length;i++){
      count+=selectedReport[i].recovered.toDouble();
      recoveredSpots.add(
          FlSpot(i.toDouble()/100000,daily? selectedReport[i].recovered.toDouble()/100000:count/100000)
      );
    }
    List temp = List.from(selectedReport);
    temp.sort((a,b)=>a.recovered.compareTo(b.recovered));
    recoveredmaxY = daily? temp.last.recovered*1.1:count*1.1;
    recoveredmaxY/=100000;
  }
  void DeathGraph(){
    deathSpots = [];
    double count = 0;
    for(int i=0; i<selectedReport.length;i++){
      count+=selectedReport[i].death.toDouble();
      print("deathGraph function "+selectedReport[i].death.toDouble().toString());
      deathSpots.add(
          FlSpot(i.toDouble()/100000, daily? selectedReport[i].death.toDouble()/100000:count/100000)
      );
    }
    List temp = List.from(selectedReport);
    temp.sort((a,b)=>a.death.compareTo(b.death));
    deathmaxY = daily? temp.last.death*1.1:count*1.1;
    deathmaxY/=100000;
    print("deathmaxy: $deathmaxY");
  }

  void loadGraphData() async{
    selectedReport = statesDailyReport.where((data)=>(data.state == selected_state)).toList();
    ConfirmedGraph();
    ActiveGraph();
    RecoveredGraph();
    DeathGraph();
    print("before maping active min: $activeminY");
    graphData = [
      {
        "maxY": confirmedmaxY,
        "minY": 0,
        "spots": confirmedSpots,
        "color": Colors.redAccent[200],
        "title": "Confirmed",

      },
      {
        "maxY": activemaxY,
        "minY": activeminY,
        "spots": activeSpots,
        "color": Colors.blueAccent[200],
        "title": "Active",

      },
      {
        "maxY": recoveredmaxY,
        "minY": 0,
        "spots": recoveredSpots,
        "color": Colors.green[400],
        "title": "Recovered",

      },
      {
        "maxY": deathmaxY,
        "minY": 0,
        "spots": deathSpots,
        "color": Colors.blueGrey[400],
        "title": "Death",

      }
    ];
  }

  @override
  void initState() {
    super.initState();
    LoadData();
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double heightRatio = height/896.0;
    double widthRatio = width/414.0;


    if(loader){
      return CoronaLoader(
        widthRatio: widthRatio,
        heightRatio: heightRatio
      );
    }

    MakeLineGraph makeLineGraph =  MakeLineGraph(
        widthRatio: widthRatio,
        heightRatio: heightRatio,
        selectedReport: selectedReport
    );

    DateTime temp = DateTime.now();


    print(temp.difference(DateTime.now()));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent[200],
        title: Text(
          "State Wise Statistic",
          style: TextStyle(
            fontSize: heightRatio*20,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: SideMenu(
          currentRoute: "/stats/state_wise"
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(widthRatio*20, heightRatio*20, widthRatio*20, heightRatio*20),
        child: Column(
          children: <Widget>[
            // heading section
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, heightRatio*10),
              child: Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Text(
                      "India",
                      style: TextStyle(
                        fontSize: heightRatio*28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: GestureDetector(
                      onTap: () async {
                        dynamic response = await Navigator.pushNamed(context, "/stats/list", arguments: {
                          "states": statesData,
                          "countriesReport": <CountryWiseReport>[],
                          "stateWiseReport": stateWiseReport,
                        });
                        selected_state = response!=null? response: selected_state;
                        loadGraphData();
                        setState(() {
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(widthRatio*15, heightRatio*5, widthRatio*15, heightRatio*5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width:widthRatio*2,
                            color: Colors.grey[800]
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(widthRatio*20))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              flex: 6,
                              fit: FlexFit.tight,
                              child: Text(
                                selected_state.state!=null? selected_state.state:"",
                                style: TextStyle(
                                  fontSize: heightRatio*15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: Icon(
                                Icons.arrow_drop_down,
                                size: heightRatio*20,
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            //select mode
            Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Daily: ",
                        style: TextStyle(
                          fontSize: heightRatio*17,
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: widthRatio*50,
                        height: heightRatio*25,
                        decoration: BoxDecoration(
                          color: daily? Colors.grey[400]:Colors.grey[200],
                          borderRadius: BorderRadius.all(Radius.circular(heightRatio*15))
                        ),
                        child: Stack(
                          children: <Widget>[
                            AnimatedPositioned(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.linear,
                              left: daily? widthRatio*25:0,
                              right: daily? 0:widthRatio*25,
                              child: InkWell(
                                onTap: () async{
                                  daily = !daily;
                                  loadGraphData();
                                  setState(() {
                                  });
                                },
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  transitionBuilder: (Widget child,Animation<double> animation){
                                    return RotationTransition(
                                      turns: animation,
                                      child: child,
                                    );
                                  },
                                  child: Icon(
                                    Icons.swap_horizontal_circle,
                                    size: heightRatio*25,
                                  ),
                                ),
                              ),
                            ),
//
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),

            Expanded(
              child: ListView.builder(
                  itemCount: graphData.length,
                  itemBuilder: (BuildContext context, int index){
                    return GraphReport(
                        heightRatio: heightRatio,
                        widthRatio: widthRatio,
                        makeLineGraph: makeLineGraph,
                        Spots: graphData[index]["spots"],
                        maxY: graphData[index]["maxY"].toDouble(),
                        minY: graphData[index]["minY"].toDouble(),
                        title: graphData[index]["title"],
                        color: graphData[index]["color"]
                    );
                  }
              ),
            ),

          ],
        ),
      ),
    );
  }
}

