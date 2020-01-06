import 'package:flutter/material.dart';
import 'package:wherethebusahrebuild/pages/HomePage.dart';

class FavouritesPage extends StatelessWidget {
  var favourites;
  FavouritesPage(this.favourites);

  @override
  Widget build(BuildContext context) {
    // TODO: Implement favourites page
    return Scaffold(
        appBar: AppBar(title: Text("Favorites")),
        body: ListView.builder(
          itemCount: this.favourites.length,
          itemBuilder: (context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context, this.favourites[index]);
              },
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(this.favourites[index]),
                ),
              ),
            );
          },
        ));
  }
}
