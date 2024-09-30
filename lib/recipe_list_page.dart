import 'package:flutter/material.dart';
import 'recipe.dart';
import 'recipe_detail_page.dart';
import 'database_helper.dart';
import 'recipe_input_page.dart';
import 'dart:io'; // Fileクラスをインポート

class RecipeListPage extends StatelessWidget {
  final List<Recipe> recipes;
  final Function(Recipe) onAdd;
  final Function(int) onDelete;

  const RecipeListPage(
      {Key? key,
      required this.recipes,
      required this.onAdd,
      required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('レシピ一覧'),
        ),
        body: ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(recipe: recipe),
                  ),
                );
              },
              child: ListTile(
                title: Text(recipe.name),
                trailing: Image.file(File(recipe.photo)),
                leading: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    onDelete(recipe.id);
                  },
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecipeInputPage()),
            );

            if (result != null &&
                result['title'] != null &&
                result['photo'] != null &&
                result['description'] != null) {
              final newRecipe = Recipe(
                id: DateTime.now().millisecondsSinceEpoch, // int型のIDを使用
                name: result['title'],
                photo: result['photo'],
                description: result['description'],
              );
              final dbHelper = DatabaseHelper();
              await dbHelper.insertRecipe(newRecipe);
              onAdd(newRecipe);
            } else {
              // ロギングフレームワークを使用
              debugPrint('タイトルや写真がnullのため、投稿できません');
            }
          },
          child: const Icon(Icons.add),
        ));
  }
}
