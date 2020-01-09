import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wherethebusahrebuild/pages/BusArrivals.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:geolocator/geolocator.dart';
import 'package:wherethebusahrebuild/pages/SearchBusStops.dart';

class HomePage extends StatefulWidget {
  final int busStopNumber;

  HomePage(this.busStopNumber);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState(this.busStopNumber);
  }
}

class _HomePageState extends State {
  String accountKey = "KEY_HERE";
  var busStopNumber;
  var busData;

  Map rawStopData = Map();
  List rawStopKeys;

  Map stopsData = Map();
  Set stopKeys = new Set();

  String busStopName;
  MapController mapController = MapController();

  // latLng of Singapore
  LatLng defaultLocation = LatLng(1.3521, 103.8198);
  LatLng currentUserLocation;

  List<String> favorites = [];

  _HomePageState(this.busStopNumber) {
    if (this.busStopNumber != null) {
      this._fetchBusData();
    }

    this._getCurrentLocation();
  }

  _fetchBusData() async {
    Fluttertoast.showToast(
        backgroundColor: Colors.red,
        msg: "Fetching Latest Data",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);

    var response = await http.get(
        "http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=" +
            this.busStopNumber.toString(),
        headers: {
          "AccountKey": this.accountKey,
        });

    Map data = jsonDecode(response.body);
    setState(() {
      if (data["Services"].length > 0) {
        this.busData = data["Services"];
      } else {
        this.busData = null;
      }
    });
  }

  _getCurrentLocation() async {
    // Show toast
    Fluttertoast.showToast(
        backgroundColor: Colors.red,
        msg: "Getting Current Location",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);

    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      this.currentUserLocation = LatLng(position.latitude, position.longitude);
    });

    this.mapController.onReady.then((result) {
      this.mapController.move(this.currentUserLocation, 17);
      this._fetchStopsData();
    });
  }

  _fetchStopsData() async {
    var response = await http.get(
        "https://raw.githubusercontent.com/cheeaun/busrouter-sg/master/data/3/stops.json");
    Map json = jsonDecode(response.body);

    // Assigns the raw stop data value
    this.rawStopData = json;
    this.rawStopKeys = json.keys.toList();

    // TODO: Set stopData and keys to only places that are within 10km of distance from the specified place
    this._assignWithinTenKM(this.currentUserLocation, json, 0.6);
  }

  _assignWithinTenKM(
      LatLng fromLocation, Map stopsData, double distanceInKilometers) {
    List keys_bus_stops = stopsData.keys.toList();

    // TODO: Set state with the places within 10 km
    setState(() {
      keys_bus_stops.forEach((bus_stop_code) {
        double lat_stop = stopsData[bus_stop_code]['lat'];
        double lng_stop = stopsData[bus_stop_code]['lng'];
        var d_meters =
            Haversine().distance(LatLng(lat_stop, lng_stop), fromLocation);

        if ((d_meters / 1000) < distanceInKilometers) {
          this.stopsData[bus_stop_code] = stopsData[bus_stop_code];
          this.stopKeys.add(bus_stop_code);
        }
      });
    });
  }

  _navigateToSearchAndAssign() async{
    // TODO: Navigate to external search page
    var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchBusStopsPage(this.rawStopData, this.rawStopKeys)));

    // TODO: Await result and assign it to this.busStopNumber
    if(result != null){
      this.busStopNumber = result.toString();
    }

    print(result);
    this._fetchBusData();
    setState(() {
      // Set the current user location to where the bus stop is
      this.currentUserLocation = LatLng(this.rawStopData[result]['lat'], this.rawStopData[result]['lng']);

      // Move the map
      mapController.move(this.currentUserLocation, 17);

      // Render the bus stops that are within a certain threshold
      this._assignWithinTenKM(this.currentUserLocation, this.rawStopData, 0.6);
    });
  }

  _showMap(LatLng currentUserLocation) {
    return FlutterMap(
      mapController: this.mapController,
      options: new MapOptions(
        center: currentUserLocation,
        zoom: 17,
      ),
      layers: [
        new TileLayerOptions(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/nabilridhwan/ck52h4bv904ks1covox35lnv5/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibmFiaWxyaWRod2FuIiwiYSI6ImNrNTJnMWxxODE3NGEza3FmeWd6bXJrOHEifQ.hRcmSVhqNRC_LeSjGRwblw",
          additionalOptions: {
            'accessToken':
                'pk.eyJ1IjoibmFiaWxyaWRod2FuIiwiYSI6ImNrNTJnMWxxODE3NGEza3FmeWd6bXJrOHEifQ.hRcmSVhqNRC_LeSjGRwblw',
            'id': 'mapbox.streets',
          },
        ),
        new MarkerLayerOptions(
          markers: (this.stopKeys != null && this.stopsData != null)
              // Builds markers using stopsdata
              ? List.generate(
                  this.stopKeys.length,
                  (index) {
                    var key = this.stopKeys.toList()[index];
                    return new Marker(
                      height: 100,
                      width: 1000,
                      point: LatLng(this.stopsData[key]['lat'],
                          this.stopsData[key]['lng']),
                      builder: (ctx) => new Container(
                        child: GestureDetector(
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.beenhere,
                                color: Theme.of(context).primaryColor,
                              ),
                              Card(
                                color: Theme.of(context).primaryColor,
                                child: Padding(
                                  padding: EdgeInsets.all(3),
                                  child: Text(
                                    this.stopsData[key]['name'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                          onTap: () {
                            // implement the bus stop assignment
                            setState(() {
                              this.busStopNumber = key.toString();
                              _fetchBusData();
                            });
                          },
                        ),
                      ),
                    );
                  },
                )
              : [],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: this.busStopNumber != null ? this._fetchBusData : null,
          backgroundColor: this.busStopNumber != null
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        appBar: AppBar(
          title: Text("WhereTheBusAh"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.location_on),
              onPressed: this._getCurrentLocation,
            ),

            IconButton(
              icon: Icon(Icons.search),
              onPressed: this._navigateToSearchAndAssign,
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            this.currentUserLocation != null
                ? _showMap(this.currentUserLocation)
                : Center(
                    child: Text("Getting current location, please wait!"),
                  ),
            (this.busData != null &&
                    this.stopsData != null &&
                    this.busStopNumber != null)
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 100,
                        child: BusArrivals(
                            this.busData, this.stopsData[this.busStopNumber], this.rawStopData),
                      ),
                    ))
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 100,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Text("Select a bus stop from the map!"),
                          ),
                        ),
                      ),
                    )),
          ],
        ));
  }
}
