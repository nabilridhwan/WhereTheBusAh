import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BusRoutesPage extends StatefulWidget {
  String busNumber;
  Map rawStopsData;

  BusRoutesPage(this.busNumber, this.rawStopsData);

  @override
  _BusRoutesPageState createState() =>
      _BusRoutesPageState(this.busNumber, this.rawStopsData);
}

class _BusRoutesPageState extends State<BusRoutesPage> {
  String busNumber;
  List busRoutesData;
  Map rawStopsData;
  String dataSetUrl =
      "https://raw.githubusercontent.com/cheeaun/busrouter-sg/master/data/3/serviceStops.json";

  _BusRoutesPageState(this.busNumber, this.rawStopsData) {
    this._fetchBusRoutes();
  }

  _fetchBusRoutes() async {
    var response = await http.get(dataSetUrl);
    Map json = jsonDecode(response.body);

    setState(() {
      this.busRoutesData = json[this.busNumber][0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: this.busRoutesData != null ? Text("To " +
            this.rawStopsData[this.busRoutesData.last]['name'],
          ) : Text("..."),
        ),
        body: this.busRoutesData != null
            ? ListView.builder(
                itemCount: this.busRoutesData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(
                          this.rawStopsData[this.busRoutesData[index]]['name']),
                      subtitle: Text(this.busRoutesData[index]));
                })
            : Text("Please Wait!"));
  }
}
