import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile/database.dart';
import 'package:mobile/display_data_screen.dart';
import 'package:mobile/recipe.dart';
import 'package:mobile/take_picture_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

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

                  if (response.statusCode == 200) {
                    final database = await $FloorAppDatabase
                        .databaseBuilder('app_database.db')
                        .build();

                    // Создаем экземпляр сущности Recipe
                    final recipe = Recipe(response: 'Ваш текст рецепта');

                    // Вставляем рецепт в базу данных
                    await database.recipeDao.insertRecipe(recipe);
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
