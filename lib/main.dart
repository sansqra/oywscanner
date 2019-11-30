import 'package:flutter/material.dart';
import './login.dart';

void main() => runApp(HomePage());

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    CircularProgressIndicator();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}