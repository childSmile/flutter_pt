import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  // final detectionSpeed = DetectionSpeed.noDuplicates;
  // final detectionTimeout = 1000;
  // final selectedFormats = [BarcodeFormat.qrCode];
  // final returnImage = false;
  // final invertImage = false;
  // final autoZoom = true;

  // late MobileScannerController scannerController = initController();

  // MobileScannerController initController() => MobileScannerController(
  //       cameraResolution: const Size(200, 200),
  //       detectionSpeed: detectionSpeed,
  //       detectionTimeoutMs: detectionTimeout,
  //       formats: selectedFormats,
  //       returnImage: returnImage,
  //       torchEnabled: true,
  //     );

  String _result = "";

  Future<void> _downloadFileFromUrl(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      debugPrint("response ${response.statusCode} , ${response.bodyBytes}");
      if (response.statusCode == 200) {
        Navigator.pop(context, response.bodyBytes);

        // final directory = (await getApplicationDocumentsDirectory()).path;
        // final filePath = '$directory/${url.split("/").last}';
        // File file = File(filePath);
        // await file.writeAsBytes(response.bodyBytes);
        // debugPrint("file download to $filePath");
      } else {
        throw "Failed to down file,status code： ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("down file error ==$e");
    }
  }

  @override
  void dispose() {
    // scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Code'),
        actions: [
          TextButton(
            onPressed: () {
              onPressed();
              // scannerController.toggleTorch();
            },
            child: const Text('Torch'),
          ),
        ],
      ),
      body: Text("Scanner"),
      // MobileScanner(
      //   controller: scannerController,
      //   onDetect: (res) {
      //     if (res.barcodes.first.rawValue == null) {
      //       debugPrint('Failed to scan Barcode');
      //     } else {
      //       _result = res.barcodes.first.rawValue!;
      //       debugPrint('Barcode found! $_result');
      //     }
      //   },
      // ),
    );
  }

  void onPressed() async {}
}
