import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:covid19app/data/DataFormat.dart';

class GlobalCountryReport extends StatefulWidget {
  @override
  _GlobalCountryReportState createState() => _GlobalCountryReportState();
}

class _GlobalCountryReportState extends State<GlobalCountryReport> {

  List<Countries> countries = <Countries>[];
  List<CountryWiseReport> countryWiseReport = <CountryWiseReport>[];
  List<Widget> countriesReport = <Widget>[];
  bool initial = true;
  bool search = false;

  String country = "";

  // sort the country based on total confirmed cases
  void sortReports() {
    countryWiseReport.sort((a,b)=>b.confirmed.compareTo(a.confirmed));
  }

  // country report card
  void countryReportCard({double widthRatio, double heightRatio, dynamic numFormat}) {
    List reports;
    if(country == ""){
      reports = countryWiseReport.sublist(1);
    }else{
      reports = countryWiseReport.sublist(1).where((report)=>report.country.Country.toLowerCase().contains(country.toLowerCase())).toList();
    }
    countriesReport = reports.map((data) {
      return Card(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(widthRatio*20, heightRatio*10, widthRatio*20, heightRatio*10),
              child: Row(
                children: <Widget>[
                  Flexible(
                    flex: 5,
                    fit: FlexFit.tight,
                    child: Text(
                      data.country.Country,
                      style: TextStyle(
                        fontSize: heightRatio*20,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Text(
                      numFormat.format(data.confirmed),
                      style: TextStyle(
                        fontSize: heightRatio*18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent[100],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(widthRatio*20, heightRatio*0, widthRatio*20, heightRatio*15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: widthRatio*100,
                    height: heightRatio*40,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent[100],
                      borderRadius: BorderRadius.all(Radius.circular(widthRatio*10))
                    ),
                    child: Center(
                      child: Text(
                        numFormat.format(data.active),
                        style: TextStyle(
                          fontSize: heightRatio*14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: widthRatio*7,
                  ),
                  Container(
                    width: widthRatio*100,
                    height: heightRatio*40,
                    decoration: BoxDecoration(
                        color: Colors.green[200],
                        borderRadius: BorderRadius.all(Radius.circular(widthRatio*10))
                    ),
                    child: Center(
                      child: Text(
                        numFormat.format(data.recovered),
                        style: TextStyle(
                            fontSize: heightRatio*14.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: widthRatio*7,
                  ),
                  Container(
                    width: widthRatio*100,
                    height: heightRatio*40,
                    decoration: BoxDecoration(
                        color: Colors.blueGrey[200],
                        borderRadius: BorderRadius.all(Radius.circular(widthRatio*10))
                    ),
                    child: Center(
                      child: Text(
                        numFormat.format(data.death),
                        style: TextStyle(
                            fontSize: heightRatio*14.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: widthRatio*7,
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }).toList();
    print("lenfth: ${countriesReport.length}");
  }

  @override
  Widget build(BuildContext context) {

    dynamic response = ModalRoute.of(context).settings.arguments;
    countries = response["countries"];
    countryWiseReport = response["countryWiseReport"];

    sortReports();

    dynamic numFormat = NumberFormat( '###,###', 'en_US');

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double heightRatio = height/896.0;
    double widthRatio = width/414.0;

    countryReportCard(
      widthRatio: widthRatio,
      heightRatio: heightRatio,
      numFormat: numFormat
    );

    dynamic titleBar = Text(
        "Country Wise Report",
        style: TextStyle(
        fontSize: heightRatio*20,
      ),
    );

    dynamic searchBar = Container(
      height: 35,
      child: TextField(
        textInputAction: TextInputAction.done,
        onChanged: (keyword) {
          setState(() {
            country = keyword;
          });
        },
        decoration: InputDecoration(
          hintText: "Country Name",
          hintStyle: TextStyle(
            color: Colors.white,
            fontSize: heightRatio*17,
          ),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              )
          ),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              )
          ),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.redAccent[200],
        title: search ? searchBar:titleBar,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: search? Icon(Icons.close):Icon(Icons.search),
            onPressed: () {
              setState(() {
                print("search: ${!search}");
                search = !search;
                country = "";
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(widthRatio*20, heightRatio*10, widthRatio*20, heightRatio*30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            //Global Report
            Card(
              child: Padding(
                padding: EdgeInsets.fromLTRB(widthRatio*10, heightRatio*15, widthRatio*10, heightRatio*15),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Global",
                          style: TextStyle(
                            fontSize: heightRatio*20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: heightRatio*10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: widthRatio*150,
                          height: heightRatio*55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(widthRatio*10)),
                            color: Colors.redAccent[100],

                          ),
                          child: Center(
                            child: Text(
                              numFormat.format(countryWiseReport[0].confirmed),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: heightRatio*16,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: widthRatio*20,
                        ),
                        Container(
                          width: widthRatio*150,
                          height: heightRatio*55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(widthRatio*10)),
                            color: Colors.blueAccent[100],

                          ),
                          child: Center(
                            child: Text(
                              numFormat.format(countryWiseReport[0].active),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: heightRatio*16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: heightRatio*10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: widthRatio*150,
                          height: heightRatio*55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(widthRatio*10)),
                            color: Colors.green[200],

                          ),
                          child: Center(
                            child: Text(
                              numFormat.format(countryWiseReport[0].recovered),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: heightRatio*16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: widthRatio*20,
                        ),
                        Container(
                          width: widthRatio*150,
                          height: heightRatio*55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(widthRatio*10)),
                            color: Colors.blueGrey[200],

                          ),
                          child: Center(
                            child: Text(
                              numFormat.format(countryWiseReport[0].death),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: heightRatio*16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),

            // Guide to Colors
            Container(
              padding: EdgeInsets.fromLTRB(0, heightRatio*10, 0, heightRatio*10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(widthRatio*40, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.redAccent[100],
                                radius: widthRatio*7,
                              ),
                              SizedBox(
                                width: widthRatio*10,
                              ),
                              Text(
                                "Total Confirmed",
                                style: TextStyle(
                                  fontSize: widthRatio*15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(widthRatio*10, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.green[200],
                                radius: widthRatio*7,
                              ),
                              SizedBox(
                                width: widthRatio*10,
                              ),
                              Text(
                                "Total Recovered",
                                style: TextStyle(
                                  fontSize: widthRatio*15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(widthRatio*40, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.blueAccent[100],
                                radius: widthRatio*7,
                              ),
                              SizedBox(
                                width: widthRatio*10,
                              ),
                              Text(
                                "Total Active",
                                style: TextStyle(
                                  fontSize: widthRatio*15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(widthRatio*10, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.blueGrey[200],
                                radius: widthRatio*7,
                              ),
                              SizedBox(
                                width: widthRatio*10,
                              ),
                              Text(
                                "Total Death",
                                style: TextStyle(
                                  fontSize: widthRatio*15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),

            // Country Wise Report
            Expanded(
              child: ListView(
                children: countriesReport,
              ),
            )
          ],
        ),
      ),
    );
  }
}
