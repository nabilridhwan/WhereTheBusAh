import 'package:flutter/material.dart';

class BusArrivals extends StatefulWidget {
  final busData;

  BusArrivals(this.busData);

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
      return "U";
    }
  }

  _returnType(String typeStringFromData) {
    if (typeStringFromData != "") {
      return typeStringFromData.toString();
    } else {
      return "U";
    }
  }

  _returnLoad(String loadStringFromData) {
    if (loadStringFromData != "") {
      return loadStringFromData;
    } else {
      return "U";
    }
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.busData != null
        ? ListView.builder(
            itemCount: this.widget.busData.length,
            itemBuilder: (context, int index) {
              return Card(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Text(
                        this.widget.busData[index]["ServiceNo"],
                        style: TextStyle(fontSize: 25),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  _returnMinutes(this.widget.busData[index]
                                      ['NextBus']['EstimatedArrival']),
                                ),
                                Text(
                                  _returnType(this.widget.busData[index]
                                      ['NextBus']['Type']),
                                ),
                                Text(
                                  _returnLoad(this.widget.busData[index]
                                      ['NextBus']['Load']),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  _returnMinutes(this.widget.busData[index]
                                      ['NextBus2']['EstimatedArrival']),
                                ),
                                Text(
                                  _returnType(this.widget.busData[index]
                                      ['NextBus2']['Type']),
                                ),
                                Text(
                                  _returnLoad(this.widget.busData[index]
                                      ['NextBus2']['Load']),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  _returnMinutes(this.widget.busData[index]
                                      ['NextBus3']['EstimatedArrival']),
                                ),
                                Text(
                                  _returnType(this.widget.busData[index]
                                      ['NextBus3']['Type']),
                                ),
                                Text(
                                  _returnLoad(this.widget.busData[index]
                                      ['NextBus3']['Load']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          )
        : Center(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.help,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    "Enter your Bus Stop Code and click the enter button on the keyboard!",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Click the Floating Button on the bottom right to reveal two extra buttons which allows you to favourite your bus stop and go to your favourites page!",
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    "To update the bus arrivals timing, just pull to refresh!",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
  }
}
