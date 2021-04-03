import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:async' show Future;
import 'dart:convert';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String _scanBarcode = '';
  int counter = 10;
  var jsonResponse;

  //TODO Change URL Here...
  var url = 'https://jsonplaceholder.typicode.com/todos';

  Future getWebService() async {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      jsonResponse = jsonDecode(response.body);
      print('Response: $jsonResponse');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#00FF00", "Cancel", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _scanBarcode = barcodeScanRes;
    });
    Future.delayed(const Duration(seconds: 10), () {
      scanBarcodeNormal();
    });
  }

  @override
  void initState() {
    super.initState();
    getWebService();
    scanBarcodeNormal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/logo.jpg'),
            Text('Barcode Result: $_scanBarcode'),
            FutureBuilder(
              future: getWebService(),
              builder: (context, snapshot){
                print('snapshot');
                print(snapshot);
                if(snapshot.hasError)
                  return Text('Error: ${snapshot.error}');
                else if (snapshot.data == ConnectionState.waiting){
                  return CircularProgressIndicator();
                }
                else
                  return Text(jsonResponse[0].toString());
              },
            ),
          ],
        ),
      ),
    );
  }
}

