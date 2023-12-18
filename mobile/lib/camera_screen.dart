import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile/take_picture_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  CameraScreen({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите действие'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TakePictureScreen(cameras: cameras),
                  ),
                );
              },
              child: Text('Сфотографировать'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);

                if (pickedFile != null) {
                  // Обработка выбранного изображения из галереи
                  print('Выбрано из галереи: ${pickedFile.path}');

                  // Здесь вы можете добавить ваш запрос на бэкенд для изображения из галереи
                  String apiUrl = "https://example.com/upload";

                  var request =
                      http.MultipartRequest('POST', Uri.parse(apiUrl));
                  request.files.add(await http.MultipartFile.fromPath(
                      'image', pickedFile.path));

                  var response = await request.send();

                  if (response.statusCode == 200) {
                    // Успешный ответ от сервера
                    print('Image uploaded successfully');
                  } else {
                    // Обработка ошибки
                    print(
                        'Failed to upload image. Status code: ${response.statusCode}');
                  }
                }
              },
              child: Text('Загрузить из галереи'),
            ),
          ],
        ),
      ),
    );
  }
}
