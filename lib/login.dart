import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
//import 'dart:async';
import 'dart:convert';
import './qr.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  final baseLog = "http://dev-api.orlemyouthweek.in/login";

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

  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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


  @override
  Widget build(BuildContext context) {
    _portraitModeOnly();
    return Scaffold(
      appBar: AppBar(
        title: Text('OYW Scanner'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 170),

                  TextField(
                    controller: username,
                    decoration: InputDecoration(
                      hintText: 'Enter username',
                    ),

                  ),
                  
                  SizedBox(
                      height: 40,
                    ),

                  TextField(
                    controller: password,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                    ),
                    obscureText: true,

                  ),

                  SizedBox(height: 40.0),

                  RaisedButton(
                    color: Colors.lightBlue,
                    child: Text(
                      'Login',
                      style:TextStyle(
                        fontSize: 20,
                        color: Colors.white
                      )
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
          )
        ],
      ),
    );
  }
}