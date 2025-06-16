import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Future<String?> scanBarcode(BuildContext context) async {
  final barcode = await Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => const BarcodeScanner()));
  return barcode?.rawValue;
}

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  Barcode? _barcode;
  bool didPop = false;

  Widget _buildBarcode(Barcode? value) {
    if (value == null) {
      return const Text(
        'Scanne den Schüler-QR code!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      value.displayValue ?? 'No display value.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
      });
      if (_barcode != null && mounted && !didPop) {
        Navigator.of(context).pop(_barcode);
        didPop = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Code')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _handleBarcode,
            overlayBuilder: (context, constraints) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: constraints.maxHeight / 3,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: constraints.maxHeight / 3,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                  Positioned(
                    top: constraints.maxHeight / 3,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: constraints.maxHeight / 3,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 100,
              color: Colors.black.withOpacity(0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Center(child: _buildBarcode(_barcode))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
