import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:covid19app/data/DataFormat.dart';

class ServiceDetails extends StatefulWidget {
  @override
  _ServiceDetailsState createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {

  Services serviceData;

  List<Widget> ContactNo({@required double heightRatio, @required double widthRatio}){
    List<Widget> data = <Widget>[
      Text(
        "Contact No.: ",
        style: TextStyle(
          fontSize: widthRatio*17,
          fontWeight: FontWeight.bold
        ),
        overflow: TextOverflow.clip,
      )
    ];
    print(serviceData.phone);

    serviceData.phone.split("\n").map((number) {
      data.add(
        GestureDetector(
          onTap: () async{
            if (await canLaunch("tel:$number")) {
              await launch("tel:$number");
            } else {
              print("can't dail $number");
            }
          },
          child: Text(
            " $number ",
            style: TextStyle(
                fontSize: widthRatio*16,
                color: Colors.blue
            ),
            overflow: TextOverflow.visible,
          ),
        ),
      );
    }).toList();

    return data;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double heightRatio = height/896.0;
    double widthRatio = width/414.0;

    dynamic responseData = ModalRoute.of(context).settings.arguments;
    serviceData = responseData["resource"];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.redAccent[200],
        centerTitle: true,
        title: Text(
          "Resource Details",
          style: TextStyle(
            fontSize: widthRatio*21
          ),
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(widthRatio*20, heightRatio*10, widthRatio*20, heightRatio*10),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(widthRatio*20, heightRatio*15, widthRatio*20, heightRatio*15),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              serviceData.organisation,
                              style: TextStyle(
                                fontSize: widthRatio*20,
                                fontWeight: FontWeight.bold
                              ),
                              overflow: TextOverflow.clip,
                            )
                          ),
                        ],
                      ),
                      SizedBox(
                        height: heightRatio*7,
                      ),
                      Row(
                        children: <Widget>[
                          Flexible(
                              child: Text(
                                serviceData.category,
                                style: TextStyle(
                                  fontSize: widthRatio*18,
                                ),
                                overflow: TextOverflow.clip,
                              )
                          ),
                        ],
                      ),
                      SizedBox(
                        height: heightRatio*8,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Website:",
                            style: TextStyle(
                              fontSize: widthRatio*17,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Flexible(
                            child: GestureDetector(
                              onTap: () async{
                                if (await canLaunch(serviceData.link)) {
                                  await launch(serviceData.link);
                                } else {
                                  print("can't open ${serviceData.link}");
                                }
                              },
                              child: Text(
                                " ${serviceData.link}",
                                style: TextStyle(
                                  fontSize: widthRatio*16,
                                  color: Colors.blue
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: heightRatio*22,
                      ),
                      Row(
                        children: <Widget>[
                          Flexible(
                              child: Text(
                                serviceData.description,
                                style: TextStyle(
                                  fontSize: widthRatio*18,
                                ),
                                overflow: TextOverflow.clip,
                              )
                          ),
                        ],
                      ),
                      SizedBox(
                        height: heightRatio*22,
                      ),
                      Row(
                        children: <Widget>[
                          Flexible(
                              child: Text(
                                "${serviceData.city} (${serviceData.state})",
                                style: TextStyle(
                                  fontSize: widthRatio*18,
                                  fontWeight: FontWeight.bold
                                ),
                                overflow: TextOverflow.clip,
                              )
                          ),
                        ],
                      ),
                      SizedBox(
                        height: heightRatio*18,
                      ),
                      Container(
                        width: double.infinity,
                        child: Wrap(
                          children: ContactNo(
                            widthRatio: widthRatio,
                            heightRatio: heightRatio
                          ),
                        ),
                      ),
                      SizedBox(
                        height: heightRatio*10,
                      ),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              "Click on number to dial & on link to open website",
                              style: TextStyle(
                                fontSize: widthRatio*16
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
