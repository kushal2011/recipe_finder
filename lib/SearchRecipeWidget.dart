import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_finder/RecipeWeb.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class SearchRecipeWidget extends StatefulWidget {
  static String tag = 'recipie-page';

  @override
  State createState() => new _SearchRecipeWidget();
}

class _SearchRecipeWidget extends State<SearchRecipeWidget> {
  List<Recipe> _items = new List();

  final subject = new PublishSubject<String>();

  bool _isLoading = false;
  TextEditingController textEditingController = TextEditingController(text: '');

  //this method will be called everytime there is an change of text in our search bar
  void _textChanged(String text) {
    if (text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      _clearList();
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _clearList();
    http
        .get("http://www.recipepuppy.com/api/?q=$text")//here $text will take text from our search bar
        .then((response) => response.body)
        .then(JSON.decode)
        .then((map) => map["results"])
        .then((list) {
      list.forEach(_addItem);//it adds all the recipe items to our list
    })
        .catchError(_onError)
        .then((e) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _onError(dynamic d) {
    setState(() {
      _isLoading = false;
    });
  }

  //clear all items from the list
  void _clearList() {
    setState(() {
      _items.clear();
    });
  }

  //add an item to the list
  void _addItem(item) {
    setState(() {
      _items.add(Recipe.fromJson(item));
    });
  }

  @override
  void initState() {
    super.initState();
    //this will be called at the start of the activity,it will create a stream which will listen to change in text of our search bar
    subject.stream
        .debounce(new Duration(milliseconds: 600))
        .listen(_textChanged);
  }

  //creates search bar
  Widget _createSearchBar(BuildContext context) {
    return new Card(
        child: Row(
          children: <Widget>[
            new IconButton(
              icon: Icon(Icons.arrow_back),
              //clearData method will be called when this button will be pressed
              onPressed: () => clearData(),
            ),
            new Expanded(
                child: TextField(
                  autofocus: true,
                  controller: textEditingController,
                  decoration: new InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.0),
                    hintText: 'Search Recipies here',
                  ),
                  onChanged: (string) => (subject.add(string)),
                ))
          ],
        ));
  }
  clearData(){
    subject.add("");
    textEditingController.text="";
  }

  //creates view for each item in listview
  Widget _createRecipeItem(BuildContext context, Recipe recipe) {
    return new GestureDetector( //listens for on tap
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeWeb(url: recipe.href,item: recipe.title),//goes to the next page & passes value of url and title to it
          ),
        );
        },
      child: Column(
        children: <Widget>[
          Padding(
              padding: new EdgeInsets.all(8.0),
              child: new Row(
                children: <Widget>[
                  new Image.network(recipe.thumbnail,
                      height: 80.0, width: 80.0, fit: BoxFit.fitHeight),
                  Expanded(
                      child: Container(
                        height: 80.0,
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        child: _createRecipeItemDescriptionSection(context, recipe),
                      )),
                ],
              )),

          new Divider(height: 15.0,color: Colors.black,),

        ],
      ),
    );
  }

  Widget _createRecipeItemDescriptionSection(BuildContext context, Recipe recipe) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          recipe.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        SizedBox(height: 10.0),
        Text(
          recipe.ingredients,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(600.0),
        child: const Text(''),
      ),
      body: new Container(
        padding:
        new EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: 8.0),
        child: new Column(
          children: <Widget>[
            _createSearchBar(context),
            new Expanded(
              child: Card(
                child: _isLoading
                    ? Container(
                  child: Center(child: CircularProgressIndicator()),
                  padding: EdgeInsets.all(16.0),
                )
                    : new ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  itemCount: _items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _createRecipeItem(context, _items[index]);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//a podo(plain old dart object) class
class Recipe {
  String title, thumbnail, href, ingredients;
  Recipe(
      {this.title,
        this.href,
        this.ingredients,
        this.thumbnail,});

  Recipe.fromJson(dynamic recipe) {

    try {
      this.title = recipe['title'];
      this.href=recipe['href'];
      this.ingredients = recipe['ingredients'];
      this.thumbnail = (recipe['thumbnail']);
      if(recipe['thumbnail'].toString().length==0){
        this.thumbnail = 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/No_image_available_600_x_450.svg/600px-No_image_available_600_x_450.svg.png';
      }

    } catch (e) {
      print("something happened"+e.toString());
    }
  }
}
