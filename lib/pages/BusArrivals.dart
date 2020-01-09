import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:wherethebusahrebuild/pages/BusRoutesPage.dart';
import 'package:wherethebusahrebuild/pages/HomePage.dart';

class BusArrivals extends StatefulWidget {
  final busData;
  Map rawStopData = Map();
  final currentBusStopData;

  BusArrivals(this.busData, this.currentBusStopData, this.rawStopData);

  @override
  _BusArrivalsState createState() => _BusArrivalsState();
}

class _BusArrivalsState extends State<BusArrivals> {
  _returnMinutes(String formattedString) {
    if (formattedString != "") {
      DateTime estimatedArrival = DateTime.parse(formattedString);
      if (estimatedArrival.difference(DateTime.now()).inMinutes > 0) {
        return estimatedArrival.difference(DateTime.now()).inMinutes.toString();
      } else {
        return "A";
      }
    } else {
      return "?";
    }
  }

  _returnType(String typeStringFromData) {
    if (typeStringFromData != "") {
      if (typeStringFromData == "DD") {
        return "Double";
      } else if (typeStringFromData == "SD") {
        return "Single";
      } else if (typeStringFromData == "BD") {
        return "Bendy";
      }
    } else {
      return "?";
    }
  }

  Color _returnLoadColor(String loadStringFromData) {
    if (loadStringFromData != "") {
      if (loadStringFromData == "SEA") {
        return Colors.black;
      } else if (loadStringFromData == "SDA") {
        return Colors.orange;
      }
      if (loadStringFromData == "LSD") {
        return Colors.red;
      }
    } else {
      return Colors.black;
    }
  }

  _showMap(LatLng busPos, LatLng fromBusStopPos) {
    return FlutterMap(
      options: new MapOptions(
        // Find the centerpoint between two LatLng
        center: LatLng((busPos.latitude + fromBusStopPos.latitude) / 2,
            (busPos.longitude + fromBusStopPos.longitude) / 2),
        zoom: 15,
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
        new MarkerLayerOptions(markers: <Marker>[
          Marker(
            height: 100,
            width: 100,
            point: busPos,
            builder: (ctx) => new Container(
              child: Icon(
                Icons.directions_bus,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Marker(
            height: 100,
            width: 200,
            point: fromBusStopPos,
            builder: (ctx) => new Container(
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: this.widget.busData.length,
      itemBuilder: (context, int index) {
        return Container(
          width: 200,
          child: GestureDetector(
            onLongPress: () {
              LatLng latlng_buspos = LatLng(
                  double.parse(
                      this.widget.busData[index]['NextBus']['Latitude']),
                  double.parse(
                      this.widget.busData[index]['NextBus']['Longitude']));

              LatLng latlng_currentBusStopPos = LatLng(
                  this.widget.currentBusStopData['lat'],
                  this.widget.currentBusStopData['lng']);
              // Alert user when you dont know the location of the bus!
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
//                      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      title: Text("Next bus location"),
                      content: Container(
                        child: (latlng_buspos.longitude != 0 &&
                                latlng_buspos.latitude != 0)
                            ? _showMap(latlng_buspos, latlng_currentBusStopPos)
                            : Text(
                                "Chill la bro, I don't even know the location of the bus oi!"),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("THANKS LAH!"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  });
            },
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BusRoutesPage(this.widget.busData[index]["ServiceNo"], this.widget.rawStopData)));
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    this.widget.busData[index]["ServiceNo"],
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            _returnMinutes(this.widget.busData[index]['NextBus']
                                ['EstimatedArrival']),
                            style: TextStyle(
                                color: _returnLoadColor(this
                                    .widget
                                    .busData[index]['NextBus']['Load'])),
                          ),
                          Text(
                            _returnType(
                                this.widget.busData[index]['NextBus']['Type']),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            _returnMinutes(this.widget.busData[index]
                                ['NextBus2']['EstimatedArrival']),
                            style: TextStyle(
                                color: _returnLoadColor(this
                                    .widget
                                    .busData[index]['NextBus2']['Load'])),
                          ),
                          Text(
                            _returnType(
                                this.widget.busData[index]['NextBus2']['Type']),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            _returnMinutes(this.widget.busData[index]
                                ['NextBus3']['EstimatedArrival']),
                            style: TextStyle(
                                color: _returnLoadColor(this
                                    .widget
                                    .busData[index]['NextBus3']['Load'])),
                          ),
                          Text(
                            _returnType(
                                this.widget.busData[index]['NextBus3']['Type']),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
