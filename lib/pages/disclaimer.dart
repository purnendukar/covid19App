import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:covid19app/utils/SideMenu.dart';
import 'package:covid19app/utils/utils.dart';

class Disclaimer extends StatefulWidget {
  @override
  _DisclaimerState createState() => _DisclaimerState();
}

class _DisclaimerState extends State<Disclaimer> {

  bool initial = true;
  String disclaimer = "";

  Future<void> getData() async{
    final String disclaimerUrl = "https://script.google.com/macros/s/AKfycbzgDqqYUm0i4F-jeR26y60hlK8WJrIb0fTc9z3FYNCN_E6KuPU/exec";
    dynamic response = await http.get(disclaimerUrl+"?content_type=disclaimer");
    dynamic data = jsonDecode(response.body);
    print(data);
    disclaimer = data["data"];
    setState(() {
      initial = false;
    });
  }

  void LoadData() async{
    getData().catchError((exception){
      if(exception is SocketException){
        NoInternetDialog(
            context: context,
            callback: LoadData
        );
      }else{
        ErrorLogs(
            page: "/disclaimer",
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
    getData();
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double heightRatio = height/896.0;
    double widthRatio = width/414.0;

    if(initial){
      return CoronaLoader(
        widthRatio: widthRatio,
        heightRatio: heightRatio
      );
    }

    return Scaffold(
      drawer: Drawer(
        child:SideMenu(
          currentRoute: "/disclaimer",
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(widthRatio*60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.redAccent[200],
          centerTitle: true,
          title: Text(
            "Disclaimer",
            style: TextStyle(
              fontSize: heightRatio*22
            ),
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.menu,
                  size: widthRatio*30,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(widthRatio*25, heightRatio*15, widthRatio*25, heightRatio*25),
            child: HtmlWidget(disclaimer)
          ),
        ],
      ),
    );
  }
}
