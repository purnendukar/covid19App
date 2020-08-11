import 'package:flutter/material.dart';


class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {

  String indiaCount = "0";
  String globalCount = "0";
  double widthRatio;
  double heightRatio;

  HomeAppBar({this.indiaCount,this.globalCount, @required this.widthRatio,@required this.heightRatio}){
    print(this.globalCount);
  }

  @override
  _HomeAppBarState createState() => _HomeAppBarState();

  @override
  Size get preferredSize => Size(double.infinity, 300);
}

class _HomeAppBarState extends State<HomeAppBar> {

  @override
  Widget build(BuildContext context) {

    String indiaCount = widget.indiaCount;
    String globalCount = widget.globalCount;
    double widthRatio = widget.widthRatio;
    double heightRatio = widget.heightRatio;

    return Container(
      height: heightRatio*350,
      decoration: BoxDecoration(
        color: Colors.redAccent[200],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(widthRatio*25.0),
          bottomRight: Radius.circular(widthRatio*25.0),
        )
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(widthRatio*20, heightRatio*20, widthRatio*20, heightRatio*20),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(Icons.menu),
                    color: Colors.white,
                    iconSize: heightRatio*35,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Text(
                        "Corona Tracker",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: heightRatio*22,
//                      fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/notifications");
                    },
                    icon: Icon(Icons.notifications_active),
                    color: Colors.white,
                    iconSize: heightRatio*28,
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, heightRatio*30, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          height: heightRatio*100,
                          width: widthRatio*160,
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent[400],
                            borderRadius: BorderRadius.all(Radius.circular(widthRatio*15.0))
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(widthRatio*15, heightRatio*12, 0, 0),
                                child: Text(
                                  "India",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: heightRatio*22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: heightRatio*23,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(widthRatio*15, 0, 0, 0),
                                child: Text(
                                  "$indiaCount",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: heightRatio*20,
//                                  fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: heightRatio*100,
                          width: widthRatio*160,
                          decoration: BoxDecoration(
                              color: Colors.blueAccent[200],
                              borderRadius: BorderRadius.all(Radius.circular(widthRatio*15.0))
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(widthRatio*15, heightRatio*12, 0, 0),
                                child: Text(
                                  "Global",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: heightRatio*22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: heightRatio*23,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(widthRatio*15, 0, 0, 0),
                                child: Text(
                                  "$globalCount",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: heightRatio*20,
//                              fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
