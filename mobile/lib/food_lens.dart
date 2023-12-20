import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile/camera_screen.dart';

// ignore: camel_case_types
class mobile extends StatelessWidget {
  final List<CameraDescription> cameras;

  const mobile({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(cameras: cameras),
      debugShowCheckedModeBanner: false,
    );
  }
}
