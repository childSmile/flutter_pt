import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/data_convert_controller.dart';

class DataConvertView extends GetView<DataConvertController> {
  const DataConvertView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataConvertView'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder<String>(
              future: controller.loadData(), // Replace with a valid Future
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Text('Data: ${snapshot.data}');
                } else {
                  return const Text('No data available');
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
