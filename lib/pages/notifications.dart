import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import 'package:covid19app/utils/utils.dart';

class LogData {
  String message = "";
  String date = "";
  DateTime createdAt;

  LogData({@required this.message, @required this.date, @required this.createdAt});

}

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  static const logUrl= "https://api.covid19india.org/updatelog/log.json";
  List logs = [];

  List<Widget> notiCards = <Widget>[];
  double heightRatio;
  double widthRatio;

  Future<void> getLogs() async {
    dynamic response;
    List responseData;
    response = await http.get(logUrl);
    responseData = jsonDecode(response.body);

    logs = responseData.map((data)=>LogData(
        message: data["update"],
        createdAt: DateTime.fromMillisecondsSinceEpoch(data["timestamp"]*1000),
        date: DateFormat("dd MMM yy").format(DateTime.fromMillisecondsSinceEpoch(data["timestamp"]*1000)).toString()
    )).toList();

//    logs.sort((a,b)=>DateFormat("yyyy-MM-dd hh:mm:ss").format(b.createdAt).toString().compareTo(DateFormat("yyyy-MM-dd hh:mm:ss").format(a.createdAt).toString()));

    logs = logs.reversed.toList();
    setState(() {

      Map logGroups = groupBy(logs, (obj)=>obj.date);

      logGroups.keys.map((date) {
        notiCards.addAll([
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(widthRatio*10, heightRatio*10, widthRatio*10, heightRatio*10),
                child: Text(
                  date,
                  style: TextStyle(
                      fontSize: heightRatio*20,
                      color: Colors.redAccent[400]
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: logGroups[date].map<Widget>((obj) =>
                Card(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(widthRatio*20,heightRatio*10,widthRatio*20,0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              timeAgo(obj.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: heightRatio*15,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: heightRatio*6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: RichText(
                                overflow: TextOverflow.clip,
                                strutStyle: StrutStyle(
                                    fontSize: heightRatio*18
                                ),
                                text: TextSpan(
                                    text: obj.message,
                                    style: TextStyle(
                                        color: Colors.grey[900],
                                        fontSize: heightRatio*16
                                    )
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                )
            ).toList(),
          )
        ]);

      }).toList();

    });

  }

  void LoadData(){
    getLogs().catchError((exception){
      if(exception is SocketException){
        NoInternetDialog(
            context: context,
            callback: LoadData,
        );

      }else{
        print(exception);
        ErrorLogs(
            page: "/notifications",
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
    LoadData();
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    heightRatio = height/896.0;
    widthRatio = width/414.0;

    print(notiCards.toString());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.redAccent[200],
        title: Text(
          "Notifications",
          style: TextStyle(
            fontSize: heightRatio*22
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(widthRatio*20, heightRatio*5, widthRatio*20, heightRatio*50),
        children: <Widget>[
          Column(
            children: notiCards,
          )
        ],
      ),
    );
  }
}
