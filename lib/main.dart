import 'dart:async';
import 'dart:convert';
import 'package:weather_icons/weather_icons.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:boltiot/boltiot.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home()
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _controller = new TextEditingController();
  Bolt myBolt = new Bolt("808aa4aa-caee-40c9-9fd8-90310645b4cd", "BOLT13134188");
  int led1 = 0,led2 = 0,counter =0;
  double Temp = 0;
  bool connection = false;

  Future<void> _getTemp() async {
    http.Response data = await myBolt.analogRead("A0");
    var value = json.decode(data.body);
    double temp = (100*(int.parse(value["value"])))/1024;
    setState(() {
      Temp = temp;
    });
  }

  bool on_off_LED1(){
    if(led1 == 1){
      myBolt.digitalWrite("1", "HIGH");
      return true;
    }else {
      myBolt.digitalWrite("1", "LOW");
      return false;
    }
  }

  bool on_off_LED2(){
    if(led2 == 1){
      myBolt.digitalWrite("0", "HIGH");
      return true;
    }else {
      myBolt.digitalWrite("0", "LOW");
      return false;
    }
  }

  void countering()async{
    Timer _timer;
    Timer.periodic(Duration(seconds: 1), (timer) {
      if(counter > 0) {
        setState(() {
          counter--;
        });
      }if(counter == 0)
        buzzer();
        _timer.cancel();
    });
    return;
  }

  void buzzer()async{
    Timer _timer;
    int i = 0;
    myBolt.digitalWrite("2", "HIGH");
    Timer.periodic(Duration(seconds: 1), (timer) {
      if(i == 3){
        myBolt.digitalWrite("2", "LOW");
        _timer.cancel();
      }
      i++;
    });
    return;
  }

  void _getStatus() async{
    await myBolt.isAlive().then((value) => {
      setState((){
        var output = json.decode(value.body);
        if(output['success']){
          connection = true;
        }
      })
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getStatus();
    _getTemp();
    myBolt.digitalWrite("2", "LOW");
    myBolt.digitalWrite("0", "LOW");
    myBolt.digitalWrite("1", "LOW");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "HOME",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.lightGreenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: " AUTOMATION",
                    style:TextStyle(
                        fontWeight: FontWeight.bold,
                      fontSize: 25,
                    )),
              ]
            ),
          ),
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(WeatherIcons.thermometer),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                        "$Temp",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Set timer",
                      ),
                      onSubmitted: (String value){
                        setState(() {
                          counter = int.parse(value);
                        });
                        countering();
                        _controller.clear();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    "$counter",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("LED 1"),
                  RaisedButton(
                    onPressed: (){
                      setState(() {
                        if(led1 == 1){
                          led1 = 0;
                        }else{
                          led1 = 1;
                        }
                      });
                    },
                    child: on_off_LED1()?
                    Text("ON",style: TextStyle(color: Colors.green),)
                        :Text("OFF",style: TextStyle(color: Colors.red),),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("LED 2"),
                  RaisedButton(
                    onPressed: (){
                      setState(() {
                        if(led2 == 1){
                          led2 = 0;
                        }else{
                          led2 = 1;
                        }
                      });
                    },
                    child: on_off_LED2()?
                    Text("ON",style: TextStyle(color: Colors.green),)
                        :Text("OFF",style: TextStyle(color: Colors.red),),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                  child: connection?Text("Connected"):Text("Connecting...."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}