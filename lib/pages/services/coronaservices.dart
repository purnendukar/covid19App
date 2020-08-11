import 'dart:io';

import 'package:flutter/material.dart';

import 'package:covid19app/utils/utils.dart';
import 'package:covid19app/utils/SideMenu.dart';
import 'package:covid19app/data/DataFormat.dart';

class CoronaServices extends StatefulWidget {
  @override
  _CoronaServicesState createState() => _CoronaServicesState();
}

class _CoronaServicesState extends State<CoronaServices> {

  Icon actionIcon = Icon(Icons.search);
  bool search = false;
  List<Services> resourcesData = <Services>[];
  List cities;
  List<String> citiesCopy = [];
  List states;
  List categories;
  List<DropdownMenuItem> citiesDropDown = <DropdownMenuItem> [];
  List<DropdownMenuItem> citiesStateDropDown = <DropdownMenuItem> [];
  List<DropdownMenuItem> statesDropDown = <DropdownMenuItem> [];
  List<DropdownMenuItem> categoriesDropDown = <DropdownMenuItem> [];

  String keyword = "";

  String selectedCity;
  String selectedState;
  String selectedCategory;

  bool initial = true;
  bool loaded = false;

  void loadDropDown({double widthRatio, double heightRatio}) {
    initial = false;
    selectedCity = cities[0];
    citiesDropDown = cities.map((data) => DropdownMenuItem(
      value: data,
      child: Text(
        data,
        style: TextStyle(
          fontSize: heightRatio*17
        ),
        overflow: TextOverflow.ellipsis,
      ),
    )).toList();
    selectedState = states[0];
    statesDropDown = states.map((data) => DropdownMenuItem(
      value: data,
      child: Text(
        data,
        style: TextStyle(
            fontSize: heightRatio*17
        ),
        overflow: TextOverflow.ellipsis,
      ),
    )).toList();
    selectedCategory = categories[0];
    categoriesDropDown = categories.map((data) => DropdownMenuItem(
      value: data,
      child: Text(
        data,
        style: TextStyle(
            fontSize: heightRatio*17
        ),
        overflow: TextOverflow.ellipsis,
      ),
    )).toList();
  }

  Future<void> getData() async{
    ResourcesData resources =  ResourcesData();
    await resources.getResourcesData();

    resourcesData = resources.resourcesData;
    cities = resources.cities;
    states = resources.states;
    categories = resources.services;
    resources.states.map((state)=>Text(
      state,
      style: TextStyle(
        fontSize: 12,
      ),
    )).toList();
    setState(() {
      loaded = true;
    });
  }

  void loadData() async{

    await getData().catchError((exception){
      if(exception is SocketException){
        NoInternetDialog(
            context: context,
            callback: loadData
        );
      }else{
        ErrorLogs(
            page: "/services",
            error: exception.toString()
        );
        ErrorDialog(
            context: context,
            callback: loadData
        );
      }
    });

  }

  void filterSearch({String searchKeys}){
    List<Services> resourcesDataCopy = resourcesData;

    searchKeys = searchKeys.replaceAll(", ", ",");
    List keywords = searchKeys.split(",");

    if(selectedCity != "All Cities"){
      resourcesDataCopy = resourcesDataCopy.where((data)=>data.city==selectedCity).toList();
    }
    if(selectedState != "All States"){
      resourcesDataCopy = resourcesDataCopy.where((data)=>data.state==selectedState).toList();
    }
    if(selectedCategory != "All Services"){
      resourcesDataCopy = resourcesDataCopy.where((data)=>data.category==selectedCategory).toList();
    }

    setState(() {
      keywords.map((data) {
        resourcesDataCopy = resourcesDataCopy.where((resource)=>(resource.city==data || resource.state==data || resource.organisation==data || resource.category==data));
      }).toList();
    });
  }

  List<Widget> ServicesResults({@required double widthRatio, @required double heightRatio}){

    List<Services> resourcesDataCopy = resourcesData;

    if(selectedCity != "All Cities"){
      resourcesDataCopy = resourcesDataCopy.where((data)=>data.city==selectedCity).toList();
    }
    if(selectedState != "All States"){
      resourcesDataCopy = resourcesDataCopy.where((data)=>data.state==selectedState).toList();
    }
    if(selectedCategory != "All Services"){
      resourcesDataCopy = resourcesDataCopy.where((data)=>data.category==selectedCategory).toList();
    }

    return resourcesDataCopy.map((data) {
      return Container(
        padding: EdgeInsets.fromLTRB(0, heightRatio*5, 0, 0),
        child: GestureDetector(
          onTap: () {
            print("resource clicked");
            Navigator.pushNamed(context, "/services/details", arguments: {
              "resource": data,
            });
          },
          child: Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(widthRatio*15, heightRatio*10, widthRatio*15, heightRatio*10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          data.organisation,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: heightRatio*18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: heightRatio*5,
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          data.category,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: heightRatio*17,
                              color: Colors.grey[800]
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: heightRatio*15,
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 3,
                        fit: FlexFit.tight,
                        child: Text(
                          "${data.city} (${data.state})",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: heightRatio*15,
                              color: Colors.grey[800]
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Text(
                          "Full Details",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: heightRatio*15,
                              color: Colors.grey[800]
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();

  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double heightRatio = height/896.0;
    double widthRatio = width/414.0;

    if(initial && loaded) {
      loadDropDown(widthRatio:widthRatio, heightRatio:heightRatio);
    }

    if (initial && !loaded){
      return CoronaLoader(
          widthRatio: widthRatio,
          heightRatio: heightRatio
      );
    }

    dynamic titleField = Text(
      "Corona Services",
      style: TextStyle(
        color: Colors.white,
        fontSize: widthRatio*20,
      ),
    );

    dynamic searchField = Container(
      height: heightRatio*50,
      child: TextField(
        textInputAction: TextInputAction.search,
        controller: TextEditingController(text: keyword),
        onSubmitted: (String keyword) {
          this.keyword = keyword;
          print("submited");
          filterSearch(searchKeys:keyword);
        },
        onChanged: (String keyword) {
          this.keyword = keyword;
          filterSearch(searchKeys:keyword);
        },
        decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white
                )
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white
                )
            ),
            hintText: "Search",
            hintStyle: TextStyle(
              color: Colors.white,
              fontSize: heightRatio*20,
            )
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: heightRatio*20,
        ),
      ),
    );

    return Scaffold(
      drawer: Drawer(
        child:SideMenu(
          currentRoute: "/services",
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(widthRatio*60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.redAccent[200],
          centerTitle: true,
          title: search ? searchField : titleField,
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
      body: Container(
        padding: EdgeInsets.fromLTRB(widthRatio*30, heightRatio*15, widthRatio*30, heightRatio*20),
        child: Column(
          children: <Widget>[
            Container(
              // Filters
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, widthRatio*5, 0, 0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "State",
                        contentPadding: EdgeInsets.fromLTRB(widthRatio*15, 0, widthRatio*15, 0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[700],
                            width: widthRatio*1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(widthRatio*5)),
                        )
                      ),
                      isExpanded: true,
                      value: selectedState,
                      items: statesDropDown,
                      onChanged: (item) {
                        citiesCopy = [];
                        if(item!="All States"){
                          if(item!=selectedState){
                            selectedCity = "All Cities";
                          }
                          dynamic tempResource = resourcesData.where((resource)=>resource.state==item).toList();
                          citiesStateDropDown = <DropdownMenuItem>[];
                          citiesStateDropDown.add(DropdownMenuItem(
                            value: "All Cities",
                            child: Text(
                              "All Cities",
                              style: TextStyle(
                                  fontSize: heightRatio*17
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ));
                          tempResource.map((data) {
                            if(!citiesCopy.contains(data.city)){
                              citiesCopy.add(data.city);
                              citiesStateDropDown.add(
                                  DropdownMenuItem(
                                    value: data.city.toString(),
                                    child: Text(
                                      data.city,
                                      style: TextStyle(
                                          fontSize: heightRatio*17
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                              );
                            }
                          }).toList();
                        }else{
                          citiesStateDropDown = <DropdownMenuItem>[];
                          citiesCopy = [];
                        }
                        setState(() {
                          selectedState = item;
                          print(selectedState);
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, heightRatio*15, 0, 0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "City",
                        contentPadding: EdgeInsets.fromLTRB(widthRatio*15, 0, widthRatio*15, 0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[700],
                            width: widthRatio*1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(widthRatio*5)),
                        )
                      ),
                      isExpanded: true,
                      value: selectedCity,
                      items: selectedState=="All States" ? citiesDropDown : citiesStateDropDown,
                      onChanged: (item) {
                        setState(() {
                          selectedCity = item;
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 500,
                    padding: EdgeInsets.fromLTRB(0, heightRatio*15, 0, 0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          labelText: "Service",
                          contentPadding: EdgeInsets.fromLTRB(widthRatio*15, 0, widthRatio*15, 0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[700],
                              width: widthRatio*1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(widthRatio*5)),
                          )
                      ),
                      isExpanded: true,
                      value: selectedCategory,
                      items: categoriesDropDown,
                      onChanged: (item) {
                        setState(() {
                          selectedCategory = item;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, heightRatio*10, 0, heightRatio*20),
                child: ListView(
                  children: ServicesResults(
                    widthRatio: widthRatio,
                    heightRatio: heightRatio
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


