import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:convert';
import './login.dart';

final scanPass = "https://api.orlemyouthweek.in/scan_pass";
final acceptPass = "https://api.orlemyouthweek.in/accept_pass";


class QR extends StatefulWidget {
  @override
  _QRState createState() => _QRState();
}


class _QRState extends State<QR> {

  int counter = 0;
  var client = http.Client();

  @override
  void initState(){
    super.initState();
    var android = AndroidInitializationSettings('ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, iOS);
    FlutterLocalNotificationsPlugin().initialize(initSettings, onSelectNotification: onSelectNotification);
  }

  Future<void> onSelectNotification(String payload) async{
   print('Payload nonsense');
  }


  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
 
  qrScan() async{
    var scannedQr = await FlutterBarcodeScanner.scanBarcode("#ff6666", 'Cancel', true, ScanMode.DEFAULT);
    return scannedQr;
  }

  qrValidity(scannedQr, token) async{
    var response = await http.post(
      scanPass,
      body: {
        'code': scannedQr,
      },
      headers: {
        'token': token
      }
    );
    return response;

  }


 //pass redeem, pass redeem fail


  void _invalidQR(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
            title: Text('Invalid QR'),
            content: Text('Please Scan a valid OYW QR Pass'),
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

  showNotificationS() async{
    var android = AndroidNotificationDetails('channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
    importance: Importance.Max, priority: Priority.High);
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);
    await FlutterLocalNotificationsPlugin().show(0, 'Pass Redeemed', 'SUCCESSFUL', platform);
  }

  showNotificationF() async{
    var android = AndroidNotificationDetails('channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
    importance: Importance.Max, priority: Priority.High);
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);
    await FlutterLocalNotificationsPlugin().show(0, 'Pass Redemption', 'FAILED. Try again', platform);
  }


 void confirmBox(qty, phone, type, token){
   counter = 0;
   showDialog(
     context: context,
     builder: (BuildContext context){
       return Scaffold(
         appBar: AppBar(),
         body: Container(
           child: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[

                SizedBox(height: 50),

                Text(
                  'Valid OYW Pass!',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),

                SizedBox(height: 50),

                Text(
                  'Phone number: $phone',
                  style: TextStyle(
                    fontSize: 20
                  ),
                ),

                SizedBox(height: 50),

                Text(
                  'Pass type: $type and qty: $qty',
                  style: TextStyle(
                    fontSize: 20
                  ),
                ),

                SizedBox(height: 50),


                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState){
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: (){
                            setState((){
                              if(counter != 0)
                              counter--;
                            });
                          },
                        ),
                        Text(
                          '$counter',
                          style: TextStyle(
                            fontSize: 20
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: (){
                            setState((){
                              if(counter < qty)
                              counter++;
                            });
                          },
                        )
                      ],
                    );
                  },
                ),

                SizedBox(height: 50),

                RaisedButton(
                  shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.lightBlue)
                      ),
                      color: Colors.lightBlue,
                      onPressed: ()async {
                        print('Counter: $counter, Type: $type, Phone: $phone, Token: $token');
                        print(counter.runtimeType);
                        print(acceptPass);
        
                        if(counter != 0){
                          print('above post now');
                          var response = await http.post(
                            acceptPass,

                            body: <String, String>{
                              'type': type, //string
                              'phone': phone, //string
                              'qty': counter.toString() //int. Tried sending as string too, didn't work.
                            },
                            headers: {
                              'token': token //string
                            }
                          );
                          print("something with the response here ");
                          print(response.statusCode);

                          if(response.statusCode == 200){
                            
                            showNotificationS();
                            Navigator.of(context).pop(QR());
                            
                          }
                          else{
                            //pass redeem failed
                            showNotificationF();
                            Navigator.of(context).pop(QR());
                          }
                          
                        }
                      },
                      child: Center(
                        child: Text('Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20
                          )
                        )
                      )
                )
              ]
            )
           )
         )
       );
     }
   );
 }

@override
  Widget build(BuildContext context) {
    _portraitModeOnly();
    
    return Stack(
      children: <Widget>[
        Image.asset(
          "assets/login_bck.jpg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
           body: ListView(
              children: <Widget>[
                Padding(
                padding: EdgeInsets.only(top: 15.0, left: 2.0),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Colors.red,
                    onPressed: (){
                      Navigator.pop(context,
                        MaterialPageRoute(builder: (context)=>Login(),
                        )
                      );
                    },
                  ),
                ],
              ),
            ),
              SizedBox(
                height: 220.0,
              ),
            Container(
              height: MediaQuery.of(context).size.height - 300.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(55.0),
                    topRight: Radius.circular(55.0)
                  ),
                ),
               child: ListView(
                  primary: false,
                  padding: EdgeInsets.only(
                    left: 45.0,
                    ),
                  children: <Widget>[
                    SizedBox(height: 120,),
                    FlatButton(
           
                      color: Colors.transparent,
                      child: Row(
                        children: <Widget>[
                        
                          SizedBox(width: 110,),
                          Text(
                        'Scan',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.pink[200]
                        )
                      ),
                        ]
                        ,),
                      onPressed: () async{
                        SharedPreferences prefs =  await SharedPreferences.getInstance();
                        var token = prefs.getString('token');
                        print(token);

                        var scannedQr = await qrScan(); //stores result
                        print("Gonna print the scanned result after this");
                        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@: => "+scannedQr);
                        if(scannedQr.length < 2){
                          //invalidQr();
                        }
                        else if(scannedQr.length > 2){
                          var response = await qrValidity(scannedQr, token);
                          print("Gonna print the status code here now");
                          print(response.statusCode);
                          if(response.statusCode == 200){

                            var jsonrresponse = await json.decode(response.body);
                            Map<String, dynamic> data = jsonrresponse['data'];
                            print(data);
                            confirmBox(data['qty'], data['phone'], data['type'], token);
                            
                            
                          }
                          else{
                            _invalidQR();
                          }
                        }
                      }
                    ),

                  ],
                ),
              )
            ]
          ),
        )
      ]
    );
  }
}
    