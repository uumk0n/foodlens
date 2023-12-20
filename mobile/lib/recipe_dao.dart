// recipe_dao.dart
import 'package:floor/floor.dart';

import 'recipe.dart';

@dao
abstract class RecipeDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertRecipe(Recipe recipe);

  @Query('SELECT * FROM Recipe')
  Future<List<Recipe>> getAllRecipes();
}
