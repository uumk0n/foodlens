import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile/display_picture_screen.dart';
import 'package:http/http.dart' as http;

class TakePictureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  TakePictureScreen({required this.cameras});

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сфотографировать'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            // Здесь вы можете добавить ваш запрос на бэкенд
            String apiUrl = "example.com/upload";

            var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
            request.files
                .add(await http.MultipartFile.fromPath('image', image.path));

            var response = await request.send();

            if (response.statusCode == 200) {
              // Успешный ответ от сервера
              print('Image uploaded successfully');

              // Отобразить сообщение об успешной загрузке
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Изображение успешно загружено!'),
                  duration: Duration(seconds: 2),
                ),
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DisplayPictureScreen(imagePath: image.path),
                ),
              );
            } else {
              // Обработка ошибки
              print(
                  'Failed to upload image. Status code: ${response.statusCode}');

              // Отобразить сообщение об ошибке
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ошибка при загрузке изображения'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            print('Error taking picture or uploading: $e');
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}
