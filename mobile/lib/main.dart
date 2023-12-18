import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile/food_lens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<CameraDescription> cameras = await availableCameras();
  runApp(mobile(cameras: cameras));
}
