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
  List jsonResponse = [];

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
    scanBarcodeNormal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  margin: EdgeInsets.only(left: 25),
                  alignment: Alignment.centerLeft,
                  child: Image.asset('assets/logo.jpg', width: 75, height: 75)
              ),
              Container(
                  margin: EdgeInsets.only(left: 25),
                  height: 40,
                  alignment: Alignment.centerLeft,
                  child: Text('Barcode Result: $_scanBarcode', style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14
                  ))
              ),
              FutureBuilder(
                future: getWebService(),
                builder: (context, snapshot){
                  if(snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  else if (snapshot.data == ConnectionState.waiting)
                    return CircularProgressIndicator();
                  else {
                    return GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      // itemCount: jsonResponse.length,
                      itemCount: jsonResponse.isNotEmpty? 6 : 0,
                      itemBuilder: (context, index) {
                        //ToDO Change Params Here..
                        var code = jsonResponse[index]['id'].toString();
                        var base = jsonResponse[index]['title'].toString();
                        var price = jsonResponse[index]['completed'].toString();
                        return Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('$code'),
                              //ToDO Remove maxLines: 1
                              Text('$base', maxLines: 1),
                              Text('$price')
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

