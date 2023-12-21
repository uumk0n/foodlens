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
                  String apiUrl = "http://localhost:8000/uploadfile";

                  var request =
                      http.MultipartRequest('POST', Uri.parse(apiUrl));
                  request.files.add(await http.MultipartFile.fromPath(
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

                    // Save to the database on successful image upload
                    final database = await $FloorAppDatabase
                        .databaseBuilder('app_database.db')
                        .build();

                    final recipe = Recipe(response: responseText);
                    await database.recipeDao.insertRecipe(recipe);

                    // Display the response text
                    if (responseText.isNotEmpty) {
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Response: $responseText',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    // Add a link at the bottom
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
                    );

                    // Navigate to the next screen
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DisplayDataScreen(),
                      ),
                    );
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
