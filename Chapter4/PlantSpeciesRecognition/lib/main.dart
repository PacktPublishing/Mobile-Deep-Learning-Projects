import  'package:flutter/material.dart';
import 'package:plant_species_recognition/PlantSpeciesRecognition.dart';

void main() => runApp(App());

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: PlantSpeciesRecognition()
    );
  }
}
