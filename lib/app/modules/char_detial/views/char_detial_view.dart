import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/char_detial_controller.dart';

class CharDetialView extends GetView<CharDetialController> {
  const CharDetialView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CharDetialView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CharDetialView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
