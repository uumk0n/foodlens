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
                  leading: recipes[index].imagePath != null
                      ? Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              scale: 1.0,
                              fit: BoxFit.contain,
                              image: FileImage(File(recipes[index].imagePath!)),
                            ),
                          ),
                        )
                      : null,
                  title: Text(recipes[index].response),
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
        await $FloorAppDatabase.databaseBuilder('mobile_dataBase.db').build();
    return database.recipeDao.getAllRecipes();
  }
}
