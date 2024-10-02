import 'package:flutter/material.dart';
import 'recipe.dart';
import 'database_helper.dart';
import 'recipe_list_page.dart';
import 'recipe_detail_page.dart';

void main() {
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
  List<Recipe> _favoriteRecipes = [];

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
      _favoriteRecipes = recipes.where((recipe) => recipe.isFavorite).toList();
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
  List<Recipe> favoriteRecipes = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('お気に入りのレシピ'),
      ),
      body: ListView.builder(
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favoriteRecipes[index];
          return ListTile(
            //leading: Image.memory(recipe.photo), // 写真を表示
            title: Text(recipe.name),
            subtitle: Text(recipe.description),
            trailing: Icon(
              recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: recipe.isFavorite ? Colors.red : null,
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(recipe: recipe),
                ),
              );
              if (result == true) {
                _loadFavoriteRecipes(); // 詳細ページから戻ったときにお気に入りレシピを再読み込み
              }
            },
          );
        },
      ),
    );
  }
}
