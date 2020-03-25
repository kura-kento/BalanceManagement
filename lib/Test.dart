import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  void onTapBottomNavigation(int page){
    _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context){
                      return CreatePage();
                    },
                  ),
                );
              },
              tooltip: 'Increment',
              icon: Icon(Icons.add),
            ),
          ]
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: [
          MyHomePage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _page,
          onTap: onTapBottomNavigation,
          items:[
            BottomNavigationBarItem(
                icon: Icon(Icons.dvr)
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.trending_up)
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings)
            ),
          ]
      ),

    );
  }
}


class CreatePage extends StatelessWidget {
  var default_btn = "blue";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("追加フォーム"),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: "プラス"),
              Tab(text: "マイナス")
            ],
            unselectedLabelColor: Colors.grey,
          ),

        ),
        body: TabBarView(
            children: <Widget>[
              Container(color: Colors.white,),
              Container(color: Colors.white,),
            ]),
      ),
    );
  }
}


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
