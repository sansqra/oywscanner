import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import './qr.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  final baseLog = "https://api.orlemyouthweek.in/login";

  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  togs() async{
    var response = await http.post(
      baseLog,

      body: {
        'username': username.text,
        'password': password.text
      }
    );
    var jsonres = await json.decode(response.body);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', response.headers['token']);
    print(prefs.getString('token'));
    return jsonres;
  }

  void _credentialError(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
            title: Text('Invalid Input'),
            content: Text('Credential Error. Please Check the username and password.'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {

                  Navigator.of(context).pop();
                },
              )
            ],
        );
      }
    );
  }

  Widget build(BuildContext context){
    _portraitModeOnly();
    return SafeArea(
    child: Stack(
      children: <Widget>[
        Image.asset(
          "assets/login_bck.jpg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          
          body: ListView(
            children: <Widget>[
              SizedBox(
                height: 300.0,
              ),
              //Container for login input widgets
              Container(
                height: MediaQuery.of(context).size.height - 280.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(55.0),
                    topRight: Radius.circular(55.0)
                  ),
                ),
                child: ListView(
                  primary: false,
                  padding: EdgeInsets.only(left: 25.0, right: 20.0),
                  children: <Widget>[
                    SizedBox(height: 30.0),
                    Padding(
                      padding: EdgeInsets.only(top: 45.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height - 150,
                        child: ListView(
                          children: <Widget>[
                            SizedBox(
                              height: 40.0,
                            ),
                            TextField(
                              controller: username,
                              autofocus: true,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                    hintMaxLines: 1,
                                    hintText: 'Enter username',
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft:  const  Radius.circular(40.0),
                                        topRight: const  Radius.circular(40.0),
                                        bottomLeft: const  Radius.circular(40.0),
                                        bottomRight: const  Radius.circular(40.0),
                                      ),
                                    ),
                                  ),
                            ),
                            SizedBox(height: 35.0),
                            TextField(
                                  controller: password,
                                  obscureText: true,
                                  autofocus: true,
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                  decoration: InputDecoration(
                                    hintMaxLines: 1,
                                    hintText: 'Enter password',
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft:  const  Radius.circular(40.0),
                                        topRight: const  Radius.circular(40.0),
                                        bottomLeft: const  Radius.circular(40.0),
                                        bottomRight: const  Radius.circular(40.0),
                                      ),
                                    ),
                                  ),
                                ),
                            SizedBox(height: 40.0),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.pink[100])
                                  ),
                              color:  Colors.pink[200],
                              padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white
                                    ),
                                  ),
                              onPressed: () async{
                                await togs().then((jsonres){
                                  Map<String,dynamic> data = jsonres;
                                  if(data['status'] == 'Success'){
                                    print(data['status']);
                                    username.clear(); password.clear();
                                      Navigator.push(context, 
                                      MaterialPageRoute(builder: (context) => QR())
                                      );
                                  }
                                  else{
                                    username.clear(); password.clear();
                                    _credentialError();
                                  }
                                }).catchError((err){
                                  print(err);
                                });
                              },
                            ),  
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    )
    );
  }
  
}