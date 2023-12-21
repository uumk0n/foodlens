import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile/database.dart';
import 'package:mobile/display_data_screen.dart';
import 'package:mobile/recipe.dart';
import 'package:mobile/take_picture_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';

class CameraScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  Future<String> translateToRussian(String textToTranslate) async {
    final translator = GoogleTranslator();

    final translation = await translator.translate(
      textToTranslate,
      from: 'en',
      to: 'ru',
    );

    return translation.text;
  }

  // ignore: unused_element
  Future<void> _showResultDialog(
      BuildContext context, String translatedText) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Результат'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ингредиенты: $translatedText',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Open the website when the link is tapped
                  // ignore: deprecated_member_use
                  launch('https://www.povarenok.ru/recipes/find');
                },
                child: const Text(
                  'Visit our website',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите действие'),
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
              child: const Text('Сфотографировать'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);

                if (pickedFile != null) {
                  final url =
                      Uri.parse("http://159.223.230.93:5000/uploadfile/");

                  final request = http.MultipartRequest('POST', url)
                    ..files.add(await http.MultipartFile.fromPath(
                        'image', pickedFile.path));

                  var response = await request.send();

                  String responseText = await response.stream.bytesToString();

                  if (response.statusCode == 200) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Изображение успешно загружено!'),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    Map<String, dynamic> responseData =
                        jsonDecode(responseText);
                    String result = responseData['result'];
                    List<String> lines = result.split('\\n');
                    lines.removeWhere((element) => element.isEmpty);
                    String translatedText =
                        await translateToRussian(lines.join('\n'));
                    if (translatedText.isNotEmpty) {
                      final database = await $FloorAppDatabase
                          .databaseBuilder('mobile_dataBase.db')
                          .build();

                      final recipe = Recipe(
                          response: translatedText,
                          imagePath: pickedFile.path.toString());
                      await database.recipeDao.insertRecipe(recipe);
                      // ignore: use_build_context_synchronously
                      _showResultDialog(context, translatedText);
                    }
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ошибка при загрузке изображения'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text('Загрузить из галереи'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DisplayDataScreen(),
                  ),
                );
              },
              child: const Text('Показать данные из базы'),
            ),
          ],
        ),
      ),
    );
  }
}
