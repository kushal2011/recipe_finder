import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class RecipeWeb extends StatelessWidget {
  static String tag = 'recipie-web';
  final String url;
  final String item;

  //it will take 2 parameters(url & title) from previous screen
  RecipeWeb({Key key, @required this.url,@required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Recipe for $item"),
        ),
        body:new MaterialApp(
          routes: {
            "/": (_) => new WebviewScaffold(
              url: url,
              appBar: new AppBar(
                title: new Text("Recipe"),
              ),
            )
          },
        )
    );
  }
}
