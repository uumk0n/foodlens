// database.dart
import 'package:floor/floor.dart';
import 'dart:async';

import 'package:sqflite/sqflite.dart' as sqflite;

import 'recipe.dart';
import 'recipe_dao.dart';

part 'database.g.dart'; // Добавьте эту строку

@Database(version: 1, entities: [Recipe])
abstract class AppDatabase extends FloorDatabase {
  RecipeDao get recipeDao;
}
