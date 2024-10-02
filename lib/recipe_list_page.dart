import 'package:flutter/material.dart';
import 'recipe.dart';
import 'recipe_detail_page.dart';
import 'database_helper.dart';
import 'recipe_input_page.dart';
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
        backgroundColor: const Color.fromARGB(255, 255, 240, 209),
        appBar: AppBar(
          title: Text('レシピ一覧'),
        ),
        body: ListView.builder(
          itemCount: widget.recipes.length,
          itemBuilder: (context, index) {
            final recipe = widget.recipes[index];
            return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 3.0), // 上下に8ピクセルの隙間を追加
                child: GestureDetector(
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
                  child: Container(
                    color:
                        const Color.fromARGB(255, 255, 255, 255), // ここで背景色を設定
                    height: 150.0, // リストアイテムの高さを統一
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(recipe.name,
                                    style: TextStyle(fontSize: 18.0)),
                                IconButton(
                                  icon: Icon(
                                    recipe.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        recipe.isFavorite ? Colors.red : null,
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      recipe.isFavorite = !recipe.isFavorite;
                                    });
                                    final dbHelper = DatabaseHelper();
                                    await dbHelper.updateFavoriteStatus(
                                        recipe.id, recipe.isFavorite);
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Image.file(
                            File(recipe.photo),
                            fit: BoxFit.cover, // 画像のフィット方法を設定
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
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
                ingredients: result['ingredients'] != null
                    ? List<Map<String, String>>.from(result['ingredients'])
                    : [], // nullの場合は空のリストに初期化
                steps: result['steps'] != null
                    ? List<String>.from(result['steps'])
                    : [], // nullの場合は空のリストに初期化
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
