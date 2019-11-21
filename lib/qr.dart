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
  static int currentIntValue = 0; //updates on selection of new value


  final scanPass = "http://dev-api.orlemyouthweek.in/scan_pass";
  final acceptPass = "http://dev-api.orlemyouthweek.in/accept_pass";

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

  pickQrQty(maxValue) async{
    currentIntValue = 0;
    await showDialog<int>(
      context: context,
      builder: (BuildContext context){
        return NumberPickerDialog.integer(
          minValue: 0,
          maxValue: maxValue,
          initialIntegerValue: 0,
        );
      }
    ).then((num value){
      if(value != null){
        setState(() {
          currentIntValue = value;
        });
        integerNumberPicker.animateInt(currentIntValue);
      }
    });
  }

  submitQty(selectQty, phone, type, token) async{
    var response = await http.post(
      acceptPass,
      body: {
        'type': type,
        'phone': phone,
        'qty': currentIntValue
      },
      headers: {
        'token': token
      }
    );
    return response;
  }

  void confirmBox(maxValue, phone, type, token) {
    showDialog(
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
                        height: 75.0,
                      ),
                      //Pass redemption selection
                      Text(
                        'Phone Number: ' + phone,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 35.0),
                      Text(
                        'Type: ' + type,
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),

                      SizedBox(height: 40),

                      RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.lightBlue)
                        ),
                        color: Colors.lightBlue,
                        onPressed: (){
                          pickQrQty(maxValue);
                        },

                        child: Text('Number of passes $currentIntValue'),
                        
                      ),

                      SizedBox(height: 50),

                      RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.lightBlue)
                        ),
                        color: Colors.lightBlue,
                        child: Text(
                          'Redeem Passes'
                        ),
                        onPressed: () async{
                          print("gdxgxgxxfdxdfxdx");
                          var response = await submitQty(currentIntValue, phone, type, token);
                      
                          if(response.statusCode == 200){
                            print('success');
                          }
                          else{
                            print('Please don\'t');
                          }
                        },
                      ),
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
                    print(data);
                    confirmBox(data['qty'], data['phone'], data['type'], token);
                    
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