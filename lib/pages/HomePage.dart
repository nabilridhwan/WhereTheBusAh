import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wherethebusahrebuild/pages/BusArrivals.dart';
import 'package:wherethebusahrebuild/pages/FavouritesPage.dart';
import 'package:wherethebusahrebuild/pages/SettingsPage.dart';

class HomePage extends StatefulWidget {
  final int busStopNumber;

  HomePage(this.busStopNumber);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState(this.busStopNumber);
  }
}

class _HomePageState extends State {
  var busStopNumber;
  var busData;
  TextEditingController _controller = TextEditingController();
  List<String> favorites = [];
  int _selectedIndex = 0;

  _HomePageState(this.busStopNumber) {
    if (this.busStopNumber != null) {
      this.fetchBusData();
    }

    this._assignFavourites();
  }

  fetchBusData() async {
    var response = await http.get(
        "http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=" +
            this.busStopNumber.toString(),
        headers: {
          "AccountKey": "KEY_HERE",
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

  Future<void> _refreshHandler() async {
    await fetchBusData();
  }

  _assignFavourites() async {
    var prefs = await SharedPreferences.getInstance();
    var favourites = prefs.getStringList('favourites');
    if (favourites.toList() != null) {
      this.favorites = favourites.toList();
    } else {
      this.favorites = [];
    }
  }

  _getFavourites([String busStopNumber]) {
    _assignFavourites();

    if (busStopNumber != null) {
      if (this.favorites.contains(busStopNumber.toString()))
        return true;
      else
        return false;
    }

    return this.favorites.toList();
  }

  _pushOrRemoveFavourites(String busStopNumber) async {
    var prefs = await SharedPreferences.getInstance();

    if (this.favorites.contains(busStopNumber)) {
      setState(() {
        this.favorites.remove(busStopNumber);
      });
    } else {
      setState(() {
        this.favorites.add(busStopNumber);
      });
    }

    prefs.setStringList('favourites', this.favorites).then((isdone) {
      _assignFavourites();
    });
  }

  _navigateAndAssignResult() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavouritesPage(this.favorites),
      ),
    );

    print("Result: $result");
    setState(() {
      if(result != null){
        this.busStopNumber = result;
      }
      _controller.value = TextEditingValue(text: this.busStopNumber);
      fetchBusData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WhereTheBusAh"),
      ),
      floatingActionButton: SpeedDial(
        closeManually: true,
        child: Icon(Icons.list),
        children: <SpeedDialChild>[
          SpeedDialChild(
            child: Icon(Icons.library_books),
            onTap: _navigateAndAssignResult,
          ),
          SpeedDialChild(
            child: _getFavourites(this.busStopNumber.toString())
                ? Icon(Icons.favorite)
                : Icon(Icons.favorite_border),
            onTap: () {
              this._pushOrRemoveFavourites(
                this.busStopNumber.toString(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints.loose(Size(1000, 1000)),
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      onFieldSubmitted: (input) {
                        setState(
                          () {
                            this.busStopNumber = input.toString();
                            this.fetchBusData();
                          },
                        );
                      },
                      onChanged: (input) {
                        setState(
                          () {
                            this.busStopNumber = input.toString();
                          },
                        );
                      },
                      decoration: InputDecoration(
                        labelText: "Bus Stop Code",
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).accentColor),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).accentColor),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              child: BusArrivals(this.busData),
              onRefresh: _refreshHandler,
            ),
          )
        ],
      ),
    );
  }
}
