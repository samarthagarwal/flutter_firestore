import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseApp app;
  List<String> _data = new List<String>();
  final TextEditingController _msg = new TextEditingController();
  String _sender = "Samarth";

  Future<FirebaseApp> _configure() async {
    return FirebaseApp.configure(
        name: "firebaseexample",
        options: FirebaseOptions(
            googleAppID: "",
            databaseURL: "",
            apiKey: "",
            projectID: ""));
  }

  @override
  void initState() {
    super.initState();
    this._configure().then((val) {
      print("Configured");
      this.app = val;
    });
  }

  void _handleSubmitted(String text) {
    print("Submitted Detected");

    setState(() {
      this._data.insert(0, text);
      this._msg.text = "";
    });

    Firestore firestore = Firestore(app: this.app);
    firestore.collection("flutter").add({"message": text}).then((val) {
      val.get().then((doc) {
        AlertDialog dialog = new AlertDialog(
          title: new Text("Message Sent"),
          content: new Text("Your message has been sent!"),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Regret'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ]
        );

        showDialog(context: context, child: dialog);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(10.0),
                  itemCount: this._data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            margin: const EdgeInsets.only(right: 16.0),
                            child:
                                new CircleAvatar(child: new Text(_sender[0])),
                          ),
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(_sender,
                                  style: Theme.of(context).textTheme.subhead),
                              new Container(
                                margin: const EdgeInsets.only(top: 5.0),
                                child: new Text(this._data[index]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  })),
          new Divider(),
          new Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: new Row(
                children: <Widget>[
                  new Flexible(
                    child: new TextField(
                      controller: _msg,
                      onSubmitted: _handleSubmitted,
                      decoration: new InputDecoration.collapsed(
                          hintText: "Send a message"),
                    ),
                  ),
                  new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 4.0),
                    child: new IconButton(
                        icon: new Icon(Icons.send),
                        onPressed: () => this._handleSubmitted(_msg.text)),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
