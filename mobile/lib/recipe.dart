import 'package:floor/floor.dart';

@entity
class Recipe {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String response; // Textual response
  final String imagePath; // File path to the image

  Recipe({this.id, required this.response, required this.imagePath});
}
