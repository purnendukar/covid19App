import 'package:flutter/material.dart';

class StateData{
  String state;
  String stateCode;

  StateData({
    @required this.state,
    this.stateCode,
  });
}

class District{
  String district;

  District({
    @required this.district,
  });
}

class StateWiseReport{
  StateData state;
  int confirmed = 0;
  int active = 0;
  int recovered = 0;
  int deaths = 0;
  dynamic tested = "-";
  String lastUpdated="";

  StateWiseReport({
    @required this.state,
    @required this.confirmed,
    @required this.active,
    @required this.deaths,
    @required this.recovered,
    this.tested = "-",
    this.lastUpdated,
  });
}

class IndiaTestReport {
  StateData state;
  int totalTest;
  DateTime date;

  IndiaTestReport({
    @required this.state,
    @required this.totalTest,
    @required this.date
  });

}

class StateWiseBeds{
  StateData state;
  int ICUbeds;
  int isolationBeds;
  DateTime lastUpdated;

  StateWiseBeds({
    @required this.state,
    this.ICUbeds,
    this.isolationBeds,
    this.lastUpdated
  });
}

class DistrictWiseReport{
  StateData state;
  District district;
  int confirmed = 0 ;
  String lastUpdated = "";

  DistrictWiseReport({
    @required this.state,
    @required this.district,
    this.confirmed,
    this.lastUpdated,
  });
}

class Services {
  String city;
  String state;
  String category;
  String organisation;
  String description;
  String phone;
  String link;

  Services({
    this.city,
    this.state,
    this.organisation,
    this.description,
    this.phone,
    this.link,
    this. category
  });
}

class Countries{
  String Country;
  String CountryCode;

  Countries({@required this.Country,this.CountryCode});
}

class CountryWiseReport{
  int confirmed = 0;
  int recovered = 0;
  int death = 0;
  int active = 0;
  Countries country;
  String date;

  CountryWiseReport({@required this.country, @required this.confirmed, @required this.recovered, @required this.death, this.date}){
    this.active = this.confirmed - (this.recovered + this.death);
  }
}

class StatesDailyReport {
  StateData state;
  int confirmed;
  int active;
  int recovered;
  int death;
  String date;

  StatesDailyReport({
    @required this.state,
    @required this.date,
    this.confirmed,
    this.recovered,
    this.death,
  });

  calcActive(){
    this.active = this.confirmed - (this.recovered + this.death);
  }
}
