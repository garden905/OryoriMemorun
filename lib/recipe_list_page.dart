import 'package:flutter/material.dart';
import 'recipe.dart';
import 'recipe_detail_page.dart';
import 'database_helper.dart';
import 'recipe_input_page.dart';
import 'recipe_edit_page.dart';
import 'dart:io'; // Fileクラスをインポート

class RecipeListPage extends StatefulWidget {
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
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('レシピ一覧'),
        ),
        body: ListView.builder(
          itemCount: widget.recipes.length,
          itemBuilder: (context, index) {
            final recipe = widget.recipes[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(recipe: recipe),
                  ),
                );
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('削除確認'),
                      content: Text('このレシピを削除しますか？'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('キャンセル'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('削除'),
                          onPressed: () {
                            widget.onDelete(recipe.id);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: ListTile(
                title: Text(recipe.name),
                trailing:
                    Image.file(File(recipe.photo)), // trailingを使用して画像を右側に表示
                leading: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeEditPage(recipe: recipe),
                      ),
                    );

                    if (result != null) {
                      final updatedRecipe = Recipe(
                        id: result['id'],
                        name: result['title'],
                        photo: result['photo'],
                        description: result['description'],
                      );
                      final dbHelper = DatabaseHelper();
                      await dbHelper.updateRecipe(updatedRecipe);
                      setState(() {
                        widget.recipes[index] = updatedRecipe;
                      });
                    }
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
              widget.onAdd(newRecipe);
            } else {
              // ロギングフレームワークを使用
              debugPrint('タイトルや写真がnullのため、投稿できません');
            }
          },
          child: const Icon(Icons.add),
        ));
  }
}
