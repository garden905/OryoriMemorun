import 'package:flutter/material.dart';
import 'recipe.dart';
import 'database_helper.dart';
import 'recipe_list_page.dart';
import 'recipe_detail_page.dart';
import 'dart:io';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() async {
    final dbHelper = DatabaseHelper();
    final recipes = await dbHelper.queryAllRecipes();
    setState(() {
      _recipes = recipes;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _loadRecipes(); // ページが変更されたときにデータを更新
    });
  }

  void _addRecipe(Recipe recipe) {
    setState(() {
      _recipes.add(recipe);
    });
  }

  void deleteRecipe(int id) {
    setState(() {
      _recipes.removeWhere((recipe) => recipe.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 209),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(),
          RecipeListPage(
              recipes: _recipes, onAdd: _addRecipe, onDelete: deleteRecipe),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'レシピ一覧',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<int> _favoriteRecipeIds = [];
  List<Recipe> favoriteRecipes = []; // ここにお気に入りのレシピを格納
  @override
  void initState() {
    super.initState();
    _loadFavoriteRecipes();
  }

  Future<void> _loadFavoriteRecipes() async {
    final dbHelper = DatabaseHelper.instance;
    final allRecipes = await dbHelper.queryAllRecipes();
    setState(() {
      favoriteRecipes =
          allRecipes.where((recipe) => recipe.isFavorite).toList();
    });
  }

  void _toggleFavorite(int recipeId) {
    setState(() {
      if (_favoriteRecipeIds.contains(recipeId)) {
        _favoriteRecipeIds.remove(recipeId);
      } else {
        _favoriteRecipeIds.add(recipeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 209),
      appBar: AppBar(
        title: Text('お気に入りのレシピ'),
      ),
      body: ListView.builder(
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favoriteRecipes[index];
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
                child: Container(
                  color: const Color.fromARGB(255, 255, 255, 255), // ここで背景色を設定
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
                                  color: recipe.isFavorite ? Colors.red : null,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    recipe.isFavorite = !recipe.isFavorite;
                                  });
                                  final dbHelper = DatabaseHelper();
                                  await dbHelper.updateFavoriteStatus(
                                      recipe.id, recipe.isFavorite);
                                  _toggleFavorite(recipe.id);
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
    );
  }
}
