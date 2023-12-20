import 'package:floor/floor.dart';

@entity
class Recipe {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String
      response; // Здесь предполагается, что response - это строка, а не файл, например.

  Recipe({this.id, required this.response});
}
