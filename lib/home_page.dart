import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String _scanBarcode = '';
  int counter = 10;
  Map<String, dynamic> data;

  Future<String> loadJsonData() async {
    var jsonText = await rootBundle.loadString('assets/test.json');
    setState(() => data = json.decode(jsonText));
    return 'success';
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
    loadJsonData();
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
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: data == null ? 0 : data.length + 1,
              itemBuilder: (context, index){
                var code = data['property'][index]['uomCode'];
                var base = data['property'][index]['baseQuantity'].toString();
                var price = data['property'][index]['price'].toString();
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(code),
                      Text(base),
                      Text(price)
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

