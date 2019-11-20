import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:numberpicker/numberpicker.dart';


class QR extends StatefulWidget {
  @override
  
  _QRState createState() => _QRState();
}


class _QRState extends State<QR> {

  NumberPicker integerNumberPicker;
  int curreIntValue = 0; //updates on selection of new value


  final scanPass = "http://dev-api.orlemyouthweek.in/scan_pass";

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

  void confirmBox(maxValue) async{
    await showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          content: Form(
            child: Column(
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      //title
                      Text(
                        'Valid QR',
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      //Pass redemption selection

                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    _portraitModeOnly();

    return Scaffold(
      appBar: AppBar(
        title: Text('OYW 2019'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 90),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              color: Colors.lightBlue,
              child: Text(
                'Scan',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
                )
              ),
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
                    print(data['phone']);
                    confirmBox(data['qty']);
                  }
                }

                
              }
            ),
          ],
        ),
      ),
    );
  }
}