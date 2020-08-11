import 'package:flutter/material.dart';

import 'package:covid19app/pages/home.dart';
import 'package:covid19app/pages/states.dart';
import 'package:covid19app/pages/notifications.dart';
import 'package:covid19app/pages/services/coronaservices.dart';
import 'package:covid19app/pages/services/serviceDetails.dart';
import 'package:covid19app/pages/StateDistrict.dart';
import 'package:covid19app/pages/GlobalCountryReport.dart';
import 'package:covid19app/pages/statistics/statewise.dart';
import 'package:covid19app/pages/statistics/StatesOrCountryList.dart';
import 'package:covid19app/pages/statistics/countrywise.dart';
import 'package:covid19app/pages/disclaimer.dart';
import 'package:covid19app/pages/services/serviceDetails.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  initialRoute: "/home",
  routes: <String, WidgetBuilder>{
    "/home": (context) => Home(),
    "/states": (context) => StateList(),
    "/states/district": (context) => StateDistrictWise(),
    "/notifications": (context) => Notifications(),
    "/stats/list": (context) => StatesCountryList(),
    "/stats/state_wise": (context) => StateWiseStats(),
    "/stats/country_wise": (context) => CountryWiseStats(),
    "/services": (context) => CoronaServices(),
    "/services/details": (context) => ServiceDetails(),
    "/countrywisereport": (context) => GlobalCountryReport(),
    "/disclaimer": (context) => Disclaimer(),
  },
));
