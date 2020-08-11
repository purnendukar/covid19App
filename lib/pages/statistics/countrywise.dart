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

class CountryWiseStats extends StatefulWidget {
  @override
  _CountryWiseStatsState createState() => _CountryWiseStatsState();
}

class _CountryWiseStatsState extends State<CountryWiseStats> {

  static Countries selectedCountry;
  final String countriesUrl = Domains().covidWorldDomain+"/countries";
  String countriesReportUrl = Domains().covidWorldDomain+"/country/";
  static final String globalResportUrl = Domains().covidWorldDomain+"/summary";
  List<CountryWiseReport> selectedReport = <CountryWiseReport>[];
  List<CountryWiseReport> summaryReport = <CountryWiseReport>[];
  List<Countries> counties = <Countries>[];

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
    List responseData;

    response = await http.get(globalResportUrl);
    responseData = jsonDecode(response.body)["Countries"];
//    print(responseData);

    responseData.map((country) {
      counties.add(
          Countries(
              Country: country["Country"],
              CountryCode: country["CountryCode"]
          )
      );
      summaryReport.add(
          CountryWiseReport(
              country: counties.last,
              death: country["TotalDeaths"],
              confirmed: country["TotalConfirmed"],
              recovered: country["TotalRecovered"]
          )
      );
    }).toList();

    selectedCountry = selectedCountry==null? counties.where((data)=>data.Country=="India").toList()[0]:selectedCountry;
    response = await http.get(countriesReportUrl+selectedCountry.Country);
    responseData = jsonDecode(response.body);
    print(responseData);

    selectedReport = responseData.map((data)=>CountryWiseReport(
        country: selectedCountry,
        confirmed: data["Confirmed"],
        death: data["Deaths"],
        recovered: data["Recovered"],
        date: data["Date"].toString().replaceAll("T00:00:00Z", "").replaceAll(" 00:00:00Z", "")
    )).toList();

    loader = false;
    loadGraphData();
    setState(() {});
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
            page: "/stats/country_wise?county=$selectedCountry",
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
    double daily_max = 0;
    for(int i=1; i<selectedReport.length;i++){
      daily_max = (selectedReport[i].confirmed - selectedReport[i-1].confirmed)>daily_max ? (selectedReport[i].confirmed - selectedReport[i-1].confirmed).toDouble():daily_max;
      confirmedSpots.add(
        FlSpot(i.toDouble()/100000,daily ? (selectedReport[i].confirmed - selectedReport[i-1].confirmed).toDouble()/100000:selectedReport[i].confirmed.toDouble()/100000)
      );
    }
    List temp = List.from(selectedReport);
    temp.sort((a,b)=>a.confirmed.compareTo(b.confirmed));
    confirmedmaxY = daily? daily_max*1.1:temp.last.confirmed*1.1;
    confirmedmaxY/=100000;
  }
  void ActiveGraph(){
    activeSpots = [];
    double daily_max = 0;
    for(int i=1; i<selectedReport.length;i++){
      daily_max = (selectedReport[i].active - selectedReport[i-1].active)>daily_max ? (selectedReport[i].active - selectedReport[i-1].active).toDouble():daily_max;
      activeSpots.add(
          FlSpot(i.toDouble()/100000,daily ? (selectedReport[i].active - selectedReport[i-1].active).toDouble()/100000:selectedReport[i].active.toDouble()/100000)
      );
    }
    List temp = List.from(selectedReport);
    temp.sort((a,b)=>a.active.compareTo(b.active));
    activemaxY = daily? daily_max*1.1:temp.last.active*1.1;
    activemaxY/=100000;
    activeminY = temp.first.active/100000<0? temp.first.active/100000:0;
  }
  void RecoveredGraph(){
    recoveredSpots = [];
    double daily_max = 0;
    for(int i=1; i<selectedReport.length;i++){
      daily_max = (selectedReport[i].recovered - selectedReport[i-1].recovered)>daily_max ? (selectedReport[i].recovered - selectedReport[i-1].recovered).toDouble():daily_max;
      recoveredSpots.add(
          FlSpot(i.toDouble()/100000,daily ? (selectedReport[i].recovered - selectedReport[i-1].recovered).toDouble()/100000:selectedReport[i].recovered.toDouble()/100000)
      );
    }
    List temp = List.from(selectedReport);
    temp.sort((a,b)=>a.recovered.compareTo(b.recovered));
    recoveredmaxY = daily? daily_max*1.1:temp.last.recovered*1.1;
    recoveredmaxY/=100000;
  }
  void DeathGraph(){
    deathSpots = [];
    double daily_max = 0;
    for(int i=1; i<selectedReport.length;i++){
      daily_max = (selectedReport[i].death - selectedReport[i-1].death)>daily_max ? (selectedReport[i].death - selectedReport[i-1].death).toDouble():daily_max;
      deathSpots.add(
          FlSpot(i.toDouble()/100000,daily ? (selectedReport[i].death - selectedReport[i-1].death).toDouble()/100000:selectedReport[i].death.toDouble()/100000)
      );
    }
    List temp = List.from(selectedReport);
    temp.sort((a,b)=>a.death.compareTo(b.death));
    deathmaxY = daily? daily_max*1.1:temp.last.death*1.1;
    deathmaxY/=100000;
  }

  void loadGraphData() async{
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
    await Future.delayed(Duration(seconds: 2));
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
          "Country Wise Statistic",
          style: TextStyle(
            fontSize: heightRatio*20,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: SideMenu(
          currentRoute: "/stats/country_wise",
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
                      "Global",
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
                          "states": <StateData>[],
                          "countriesReport": summaryReport,
                          "stateWiseReport": <StateWiseReport>[],
                        });
                        if(response!=null) {
                          selectedCountry = response;
                          LoadData();
                          setState(() {
                            loader = true;
                          });
                        }
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
                                selectedCountry.Country!=null? selectedCountry.Country:"",
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


