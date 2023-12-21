import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile/database.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/recipe.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logging/logging.dart';

class TakePictureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const TakePictureScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final log = Logger('ExampleLogger');

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

            // Add your backend URL
            String apiUrl = "http://159.223.230.93:5000/uploadfile";

            var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
            request.files
                .add(await http.MultipartFile.fromPath('image', image.path));

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

              String translatedText = await translateToRussian(responseText);

              if (translatedText.isNotEmpty) {
                final database = await $FloorAppDatabase
                    .databaseBuilder('mobile_dataBase.db')
                    .build();

                final recipe = Recipe(
                    response: translatedText, imagePath: image.path.toString());
                await database.recipeDao.insertRecipe(recipe);
              }

              // ignore: use_build_context_synchronously
              _showResultDialog(context, translatedText);
            } else {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ошибка при загрузке изображения'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            // Handle the exception if any
            log.shout('Error taking picture or uploading: $e');
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
