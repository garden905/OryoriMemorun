import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'recipe.dart';
import 'main.dart';

class RecipeListWidget extends StatefulWidget {
  @override
  _RecipeListWidgetState createState() => _RecipeListWidgetState();
}

class _RecipeListWidgetState extends State<RecipeListWidget> {
  List<Recipe> recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final dbHelper = DatabaseHelper.instance;
    final allRecipes = await dbHelper.queryAllRecipes();
    setState(() {
      recipes = allRecipes;
    });
  }

  void deleteRecipe(int id) {
    setState(() {
      recipes.removeWhere((recipe) => recipe.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return ListTile(
          title: Text(recipe.name),
          subtitle: Text(recipe.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: recipe.isFavorite ? Colors.red : null,
                ),
                onPressed: () async {
                  setState(() {
                    recipe.isFavorite = !recipe.isFavorite;
                  });
                  final dbHelper = DatabaseHelper.instance;
                  await dbHelper.updateFavoriteStatus(
                      recipe.id, recipe.isFavorite);
                  // ホームページに移動
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
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
                              deleteRecipe(recipe.id);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
