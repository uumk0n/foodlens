import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/database.dart';
import 'package:mobile/recipe.dart';

class DisplayDataScreen extends StatefulWidget {
  const DisplayDataScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DisplayDataScreenState createState() => _DisplayDataScreenState();
}

class _DisplayDataScreenState extends State<DisplayDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История запросов'),
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _loadDataFromDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Ошибка: ${snapshot.error}');
          } else {
            final recipes = snapshot.data ?? [];
            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(recipes[index].response),
                  subtitle: recipes[index].imagePath != null
                      ? Image.file(File(recipes[index].imagePath!))
                      : null,
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Recipe>> _loadDataFromDatabase() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    return database.recipeDao.getAllRecipes();
  }
}
