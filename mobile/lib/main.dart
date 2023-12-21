import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile/food_lens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<CameraDescription> cameras = new List.empty(growable: true);
  runApp(mobile(cameras: cameras));
}
