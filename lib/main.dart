import 'package:flutter/material.dart';
import 'package:recipe_finder/RecipeWeb.dart';
import 'package:recipe_finder/SearchRecipeWidget.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    SearchRecipeWidget.tag: (context) => SearchRecipeWidget(),
    RecipeWeb.tag: (context) =>RecipeWeb(url: null, item: null,)
  };
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Recipe Finder',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchRecipeWidget(),
      routes: routes,
    );
  }
}