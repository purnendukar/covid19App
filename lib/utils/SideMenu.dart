import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SideMenu extends StatefulWidget {
  final String currentRoute;

  SideMenu({@required this.currentRoute});

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {

  bool statsOption = false;

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double heightRatio = height/896.0;
    double widthRatio = width/414.0;

    List menu = [
      {
        "icon": Icons.home,
        "itemName": "Home",
        "route": "/home"
      },
      {
        "icon": Icons.supervisor_account,
        "itemName": "Services",
        "route": "/services"
      },
      {
        "icon": Icons.insert_chart,
        "itemName": "India",
        "route": "/stats/state_wise"
      },
      {
        "icon": Icons.insert_chart,
        "itemName": "Global",
        "route": "/stats/country_wise"
      },
      {
        "icon": Icons.info_outline,
        "itemName": "Disclaimer",
        "route": "/disclaimer"
      }
    ];
    print(widget.currentRoute);

    return Container(
//    color: Color.fromRGBO(200, 168, 122, 1),
      color: Colors.grey[200],

      child: Column(
        children: <Widget>[
          Container(
            height: heightRatio*250,
            width: double.infinity,
            child: Image(
              fit: BoxFit.cover,
              image: AssetImage("lib/assets/images/sidemenu_banner.jpg"),
            ),
          ),
          Container(
            child: Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(0, heightRatio*15, 0, 0),
                itemCount: menu.length,
                itemBuilder: (BuildContext context, int index){
                  return MenuItem(
                    widthRatio: widthRatio,
                    heightRatio: heightRatio,
                    icon: menu[index]["icon"],
                    itemName: menu[index]["itemName"],
                    route: menu[index]["route"],
                    currentRoute: widget.currentRoute,
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({
    Key key,
    @required this.heightRatio,
    @required this.widthRatio,
    @required this.icon,
    @required this.itemName,
    @required this.route,
    @required this.currentRoute
  }) : super(key: key);

  final double heightRatio;
  final double widthRatio;
  final IconData icon;
  final String itemName;
  final String route;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.fromLTRB(widthRatio*30, heightRatio*10, widthRatio*30, 0),
      height: heightRatio*50,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[400],
          )
        ),
      ),
//      child: FlatButton.icon(
//        padding: EdgeInsets.fromLTRB(widthRatio*30, 0, 0, 0),
//        onPressed: () {
//          Navigator.pushReplacementNamed(context, route);
//        },
//        icon: Icon(
//          icon,
//          color: Colors.grey[600],
//          size: heightRatio*21,
//        ),
//        label: Text(
//          itemName,
//          style: TextStyle(
//              color: Colors.grey[600],
//              fontSize: heightRatio*20,
//              fontWeight: FontWeight.normal
//          ),
//        ),
//      ),
      child: FlatButton(
        onPressed: () {
          if(route!=currentRoute) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Icon(
                icon,
                color: Colors.grey[600],
                size: heightRatio*21,
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                itemName,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: heightRatio*20,
                    fontWeight: FontWeight.normal
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

