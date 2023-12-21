import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile/database.dart';
import 'package:mobile/display_data_screen.dart';
import 'package:mobile/recipe.dart';
import 'package:mobile/result.dart';
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
                        .databaseBuilder('app_database.db')
                        .build();

                    final recipe = Recipe(response: translatedText);
                    await database.recipeDao.insertRecipe(recipe);
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ResultScreen(translatedText: translatedText),
                      ),
                    );                      
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
 