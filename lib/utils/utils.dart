import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:covid19app/data/DataFormat.dart';

String timeAgo(DateTime d) {
  Duration diff = DateTime.now().difference(d);
//  if (diff.inDays > 365)
//    return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
//  if (diff.inDays > 30)
//    return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
//  if (diff.inDays > 7)
//    return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
  if (diff.inDays > 0)
    return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
  if (diff.inHours > 0)
    return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
  if (diff.inMinutes > 0)
    return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
  return "just now";
}



class Domains {
  final String covidIndiaDomain = "https://api.covid19india.org";
  final String covidWorldDomain = "https://api.covid19api.com";
}

class CoronaLoaderData {

  List<StateData> states = <StateData>[];
  List<StateWiseReport> stateWiseReports = <StateWiseReport>[];
  List<District> districts = <District>[];
  List<DistrictWiseReport> districtWiseReports = <DistrictWiseReport>[];
  List<IndiaTestReport> indiaTestReports = <IndiaTestReport>[];
  List<CountryWiseReport> countryWiseReport = <CountryWiseReport>[];
  List<Countries> countries = <Countries>[];

  StateData selected_state;
  int globalCount = 0;

  static final String stateDistrictWiseReportUrl = Domains().covidIndiaDomain+"/state_district_wise.json";
  static final String dataUrl = Domains().covidIndiaDomain+"/data.json";
  static final String globalResportUrl = Domains().covidWorldDomain+"/summary";
  static final String indiaTestReportUrl = Domains().covidIndiaDomain+"/state_test_data.json";

  Future<Map> getData() async{
    dynamic response;

    response = await http.get(stateDistrictWiseReportUrl);
    dynamic stateDistrictWiseReport = jsonDecode(response.body);

    states = stateDistrictWiseReport.keys.map<StateData>((state) {
      StateData stateReturn = StateData(
        state: state,
      );
      stateDistrictWiseReport[state]["districtData"].keys.map((district){
        District districtResponse = District(
          district: district,
        );
        districts.add(districtResponse);
        districtWiseReports.add(DistrictWiseReport(
          state: stateReturn,
          district: districtResponse,
          confirmed: stateDistrictWiseReport[state]["districtData"][district]["confirmed"],
          lastUpdated: stateDistrictWiseReport[state]["districtData"][district]["lastupdatedtime"],
        ));

      }).toList();
      return stateReturn;
    }).toList();

    int indiaTotalTest = 0;

    response = await http.get(dataUrl);
    dynamic dataResponse = jsonDecode(response.body);

    response = await http.get(indiaTestReportUrl);
    dynamic indiaTestReportData = jsonDecode(response.body)["states_tested_data"];
    print(indiaTestReportData);

    dataResponse["statewise"].map((stateReport) {
      dynamic stateObj;
      stateObj = states.where((state)=>state.state==stateReport["state"]).toList();
      if(stateObj.isEmpty) {
        print(stateReport["state"]+" not in state");
        states.add(
            StateData(
              state: stateReport["state"],
            )
        );
        stateObj = states.where((state)=>state.state==stateReport["state"]).toList();
      }

      int totalTest = 0;
      indiaTestReportData.map((testReport) {
        if (testReport["state"] == stateObj[0].state) {
          if (testReport["totaltested"] != "") {
            totalTest = totalTest>int.parse(testReport["totaltested"])? totalTest: int.parse(testReport["totaltested"]);
          }
          indiaTestReports.add(
            IndiaTestReport(
              state: stateObj[0],
              totalTest: testReport["totaltested"] != ""? int.parse(testReport["totaltested"]) : 0,
              date: DateTime.parse(
                  DateFormat("dd/MM/yyyy").parse(testReport["updatedon"]).toString()
              )
            )
          );
        }
      }).toList();

      stateWiseReports.add(
          StateWiseReport(
              state: stateObj[0],
              confirmed: int.parse(stateReport["confirmed"]),
              active: int.parse(stateReport["active"]),
              deaths: int.parse(stateReport["deaths"]),
              recovered:  int.parse(stateReport["recovered"]),
              tested: totalTest == 0 ? "-" : totalTest.toString(),
              lastUpdated: stateReport["lastupdatedtime"]
          )
      );

      indiaTotalTest += totalTest;

    }).toList();

    List findIndia = stateWiseReports;
    findIndia.sort((a,b)=>b.active.compareTo(a.active)); // for decending order

    states.remove(findIndia[0].state);
    findIndia[0].tested = indiaTotalTest.toString();

    states.sort((a,b) {
      return a.state.toLowerCase().compareTo(b.state.toLowerCase());
    });

    List<StateData> stateList = <StateData>[findIndia[0].state];
    states.map((state) {
      stateList.add(state);
    }).toList();

    states = stateList;
    selected_state = states[0];

    response = await http.get(globalResportUrl);
    dynamic responseData = jsonDecode(response.body);
    globalCount = responseData["Global"]["TotalConfirmed"];

    countryWiseReport = responseData["Countries"].map<CountryWiseReport>((data) {
      countries.add(Countries(
        Country: data["Country"],
        CountryCode: data["CountryCode"]
      ));
      return CountryWiseReport(
        country: countries.last,
        confirmed: data["TotalConfirmed"],
        death: data["TotalDeaths"],
        recovered: data["TotalRecovered"]
      );
    }).toList();

    countries.insert(0, Countries(
      Country: "Global"
    ));

    countryWiseReport.insert(0, CountryWiseReport(
      country: countries[0],
      confirmed: responseData["Global"]["TotalConfirmed"],
      recovered: responseData["Global"]["TotalRecovered"],
      death: responseData["Global"]["TotalDeaths"],
    ));

    return {
      "states": states,
      "stateWiseReports": stateWiseReports,
      "districts": districts,
      "districtWiseReports":districtWiseReports,
      "selected_state": states[0],
      "global": globalCount,
      "countries": countries,
      "countryWiseRepoer": countryWiseReport
    };

  }
}

Widget CoronaLoader({widthRatio, heightRatio}) {
  return Scaffold(
    backgroundColor: Colors.redAccent[200],
    body: Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Corona Tracker",
            style: TextStyle(
              color: Colors.white,
              fontSize: heightRatio*40,
            ),
          ),
          Text(
            "India Fights Together Covid-19",
            style: TextStyle(
              color: Colors.white,
              fontSize: heightRatio*18,
            ),
          ),
          SizedBox(
            height: heightRatio*20,
          ),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
            backgroundColor: Colors.redAccent[200],
          ),
        ],
      ),
    ),
  );
}

class ResourcesData {
  final resourcesUrl = Domains().covidIndiaDomain+"/resources/resources.json";
  List<Services> resourcesData = <Services>[];
  List<String> states = <String>[];
  List<String> cities = <String>[];
  List<String> services = <String>[];

  Future<void> getResourcesData() async {
    dynamic response;

    response = await http.get(resourcesUrl);
    dynamic resourceData = jsonDecode(response.body);

    resourceData["resources"].map((data) {

      if (!states.contains(data["state"])){
        states.add(data["state"]);
      }
      if (!cities.contains(data["city"])){
        cities.add(data["city"]);
      }
      if (!services.contains(data["category"])){
        services.add(data["category"]);
      }

      resourcesData.add(
        Services(
          city: data["city"],
          state: data["state"],
          phone: data["phonenumber"],
          organisation: data["nameoftheorganisation"],
          description: data["descriptionandorserviceprovided"],
          link: data["contact"],
          category: data["category"],
        )
      );
    }).toList();


    states.sort((a,b)=>b.compareTo(a));
    states.add("All States");
    states = states.reversed.toList();
    cities.sort((a,b)=>b.compareTo(a));
    cities.add("All Cities");
    cities = cities.reversed.toList();
    services.sort((a,b)=>b.compareTo(a));
    services.add("All Services");
    services = services.reversed.toList();
  }
}

void NoInternetDialog({BuildContext context,Function callback, bool barrierDismissible:false}){
  double widthRatio = MediaQuery.of(context).size.width/414.0;
  double heightRatio = MediaQuery.of(context).size.width/896.0;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25*widthRatio)),
      ),
      backgroundColor: Colors.grey[600],
      title: Center(
        child: Text(
          "No Internet",
          style: TextStyle(
              color: Colors.white,
              fontSize: 45*heightRatio,
          ),
        ),
      ),
      content: Container(
        height: 400*heightRatio,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.signal_wifi_off,
              size: 140*heightRatio,
              color: Colors.white,
            ),
            SizedBox(
              height: heightRatio*30,
            ),
            Text(
              "Looks like you are offline, Try agian after sometime.",
              style: TextStyle(
                fontSize: 35*heightRatio,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: heightRatio*30,
            ),
            FlatButton(
              padding: EdgeInsets.fromLTRB( 10*widthRatio, 10*heightRatio, 10*widthRatio, 10*heightRatio),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15*widthRatio))
              ),
              onPressed: () {
                Navigator.pop(context);
                callback();
              },
              child: Text(
                "Try Again",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30*heightRatio
                ),
              ),
              color: Colors.green[400],
            ),
          ],
        ),
      ),
      actions: <Widget>[

      ],
    ),
    barrierDismissible: barrierDismissible,
  );
}

void ErrorDialog({BuildContext context,Function callback, bool barrierDismissible:false}){
  double widthRatio = MediaQuery.of(context).size.width/414.0;
  double heightRatio = MediaQuery.of(context).size.width/896.0;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25*widthRatio)),
      ),
      backgroundColor: Colors.grey[600],
      title: Center(
        child: Text(
          "Someting went wrong",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45*heightRatio,
          ),
        ),
      ),
      content: Container(
        height: 440*heightRatio,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.report,
              size: 140*heightRatio,
              color: Colors.white,
            ),
            SizedBox(
              height: heightRatio*30,
            ),
            Text(
              "Looks like something went wrong during the process. Try again after sometime.",
              style: TextStyle(
                  fontSize: 35*heightRatio,
                  color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: heightRatio*30,
            ),
            FlatButton(
              padding: EdgeInsets.fromLTRB( 10*widthRatio, 10*heightRatio, 10*widthRatio, 10*heightRatio),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15*widthRatio))
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/home");
              },
              child: Text(
                "Okay",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30*heightRatio
                ),
              ),
              color: Colors.redAccent[200],
            ),
          ],
        ),
      ),
      actions: <Widget>[

      ],
    ),
    barrierDismissible: barrierDismissible,
  );
}

void ErrorLogs({String page, String error}) async{
  final LogsURL = "https://script.google.com/macros/s/AKfycbzgDqqYUm0i4F-jeR26y60hlK8WJrIb0fTc9z3FYNCN_E6KuPU/exec";
  String datetime = DateTime.now().toString();
  Map data = {
    "page": page,
    "error": error,
    "datetime":datetime
  };
  await http.post(LogsURL,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
    },
    body: jsonEncode(data)
  );

}
