import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile/database.dart';
import 'package:mobile/display_picture_screen.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/recipe.dart';

class TakePictureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const TakePictureScreen({super.key, required this.cameras});

  @override
  // ignore: library_private_types_in_public_api
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
        title: const Text('Сфотографировать'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            // Здесь вы можете добавить ваш запрос на бэкенд
            String apiUrl = "http://localhost:8000/uploadfile";

            var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
            request.files
                .add(await http.MultipartFile.fromPath('image', image.path));

            var response = await request.send();

            if (response.statusCode == 200) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Изображение успешно загружено!'),
                  duration: Duration(seconds: 2),
                ),
              );

              // Сохранение в базу данных при успешной загрузке изображения
              final database = await $FloorAppDatabase
                  .databaseBuilder('app_database.db')
                  .build();

              // Создаем экземпляр сущности Recipe
              final recipe = Recipe(response: 'Ваш текст рецепта');

              // Вставляем рецепт в базу данных
              await database.recipeDao.insertRecipe(recipe);

              // Переход к следующему экрану
              // ignore: use_build_context_synchronously
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DisplayPictureScreen(imagePath: image.path),
                ),
              );
            } else {
              // Отобразить сообщение об ошибке
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ошибка при загрузке изображения'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            // print('Error taking picture or uploading: $e');
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
