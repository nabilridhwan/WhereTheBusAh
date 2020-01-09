import 'package:flutter/material.dart';

class SearchBusStopsPage extends StatefulWidget {
  Map stopsData;
  List stopsKeys;

  SearchBusStopsPage(this.stopsData, this.stopsKeys);

  @override
  _SearchBusStopsPageState createState() =>
      _SearchBusStopsPageState(this.stopsData, this.stopsKeys);
}

class _SearchBusStopsPageState extends State<SearchBusStopsPage> {
  Map rawStopsData;
  List rawStopsKeys;

  Map stopsData;
  List stopsKeys;

  _SearchBusStopsPageState(this.stopsData, this.stopsKeys) {
    this.rawStopsData = this.stopsData;
    this.rawStopsKeys = this.stopsKeys;
  }

  _updateStopsWithInput(input) {

    Set temp_stop_codes = new Set();

    print("Updating with $input");
    this.rawStopsKeys.forEach((bus_stop_code) {

      String input_customized = input.toString().toLowerCase();
      String stop_name_customized = this.rawStopsData[bus_stop_code]['name'].toString().toLowerCase();

      if (stop_name_customized.contains(input_customized)) {
        setState(() {
          temp_stop_codes.add(bus_stop_code);
          this.stopsKeys = temp_stop_codes.toList();
        });
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build with scaffold!
    return Scaffold(
      appBar: AppBar(title: Text("Search")),
      body: Column(
        children: <Widget>[
          TextField(
            onChanged: (input) {
              _updateStopsWithInput(input);
            },
            decoration: InputDecoration(labelText: "Search Bus Stops"),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: this.stopsKeys.toList().length,
                itemBuilder: (context, index) {
                  return ListTile(
                    // TODO Implement the text and subtitle with proper data
                    title: Text(this.stopsData[this.stopsKeys.elementAt(index)]['name']),
                    subtitle: Text(this.stopsKeys.elementAt(index)),
                    onTap: (){
                      Navigator.pop(context, this.stopsKeys.elementAt(index));
                    },
                  );
                }),
          )
        ],
      ),
    );
  }
}
