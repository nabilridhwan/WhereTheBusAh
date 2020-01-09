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
      body: Text("Hello!"),
    );
  }
}