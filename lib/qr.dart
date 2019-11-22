import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:numberpicker/numberpicker.dart';



final scanPass = "http://dev-api.orlemyouthweek.in/scan_pass";
final acceptPass = "http://dev-api.orlemyouthweek.in/accept_pass";


class QR extends StatefulWidget {
  @override
  _QRState createState() => _QRState();
}


class _QRState extends State<QR> {

  NumberPicker integerNumberPicker;
  int counter = 0;
 
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

  submitQty(type, phone, qty, token) async{
    await http.post(
      acceptPass,
      body: {
        'type': type,
        'phone': phone,
        'qty': qty 
      },
      headers: {
        'token': token
      }
    ).then((response){
        print('Have reached the .then of confirm. Status code:' + (response.statusCode as String));
        return response;
      }
    ).catchError((ex){
      print(ex);
    });
    
  }



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


 

 void confirmBox(qty, phone, type, token){
   
   showDialog(
     context: context,
     builder: (BuildContext context){
       return Scaffold(
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
                          icon: Icon(Icons.add),
                          onPressed: (){
                            setState((){
                              if(counter < qty)
                              counter++;
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
                          icon: Icon(Icons.remove),
                          onPressed: (){
                            setState((){
                              if(counter != 0)
                              counter--;
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
                        if(counter != 0){
                          var response = await submitQty(counter, phone, type, token);
                          if(response.statusCode == 200){
                            Navigator.of(context).pop(QR());
                          }
                          else{
                            print('RETRY');
                          }
                        }
                        else{
                          print('Pass select > 0');
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
                  else{
                    _invalidQR();
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