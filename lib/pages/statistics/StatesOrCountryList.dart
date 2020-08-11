import 'package:flutter/material.dart';

import 'package:covid19app/data/DataFormat.dart';
import 'package:covid19app/utils/utils.dart';
import 'package:intl/intl.dart';

class StatesCountryList extends StatefulWidget {
  @override
  _StatesCountryListState createState() => _StatesCountryListState();
}

class _StatesCountryListState extends State<StatesCountryList> {

  List<StateData> states = <StateData>[];
  List<CountryWiseReport> countriesReport = <CountryWiseReport>[];
  List<StateWiseReport> stateWiseReport = <StateWiseReport>[];
  bool initial = true;
  bool search = false;
  String keywords="";
  bool isCountry = false;

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double heightRatio = height/896.0;
    double widthRatio = width/414.0;

    String title = "";
    dynamic responseData = ModalRoute.of(context).settings.arguments;
    states = responseData["states"];
    stateWiseReport = responseData["stateWiseReport"];
    countriesReport = responseData["countriesReport"];
    countriesReport.removeWhere((data)=>data.confirmed==0);


    List<Widget> dataList = <Widget>[];

    if(states.isNotEmpty){
      title = "States";
      dataList = states.where((data)=>data.state.toLowerCase().contains(this.keywords.toLowerCase())).map((state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(heightRatio*10,widthRatio*3,heightRatio*10,0),
          child: GestureDetector(
            onTap: () {
              print(state.state);
              Navigator.pop(context, state);
            },
            child: Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(heightRatio*20,widthRatio*20,heightRatio*20,widthRatio*20),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(
                            state.state,
                            style: TextStyle(
                              fontSize: heightRatio*18,
                              color: Colors.grey[800]
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Text(
                            "Cases:\n"+stateWiseReport.where((report)=>report.state==state).toList()[0].confirmed.toString(),
                            style: TextStyle(
                              fontSize: heightRatio*15,
                              color: Colors.redAccent[400]
                            ),
                            textAlign: TextAlign.left,
                          ),
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
    }

    if(countriesReport.isNotEmpty){
      isCountry = true;
      title = "Countries";
      dataList = countriesReport.where((data)=>data.country.Country.toLowerCase().contains(this.keywords.toLowerCase())).map((data) {
        return Padding(
          padding: EdgeInsets.fromLTRB(heightRatio*10,widthRatio*3,heightRatio*10,0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context, data.country);
            },
            child: Card(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(heightRatio*20,widthRatio*20,heightRatio*20,widthRatio*20),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(
                            data.country.Country,
                            style: TextStyle(
                                fontSize: heightRatio*18,
                                color: Colors.grey[800]
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Text(
                            "Cases:\n"+data.confirmed.toString(),
                            style: TextStyle(
                                fontSize: heightRatio*15,
                                color: Colors.redAccent[400]
                            ),
                            textAlign: TextAlign.left,
                          ),
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
    }

    dynamic searchBar = Container(
      height: 35,
      child: TextField(
        textInputAction: TextInputAction.done,
        onChanged: (keyword) {
          setState(() {
            this.keywords = keyword;
          });
        },
        decoration: InputDecoration(
          hintText: "Search by Name",
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
      appBar: AppBar(
        centerTitle: true,
        title: search? searchBar :Text(
          title,
          style: TextStyle(
              fontSize: heightRatio*22
          ),
        ),
        backgroundColor: Colors.redAccent[200],
        actions: <Widget>[
          IconButton(
            icon: search? Icon(Icons.close):Icon(Icons.search),
            onPressed: () {
              setState(() {
                print("search: ${!search}");
                search = !search;
                keywords = "";
              });
            },
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, widthRatio*10, 0, widthRatio*30),
        children: dataList,
      ),
    );
  }
}
