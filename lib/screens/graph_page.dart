import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('グラフ'),
      ),
      body: Text('グラフ'),
      floatingActionButton: FloatingActionButton(
          onPressed: (){

          }
      ),
    );
  }
}