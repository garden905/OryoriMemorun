import 'package:flutter/material.dart';
import 'recipe.dart';
import 'database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'recipe_detail_page.dart';
import 'package:path_provider/path_provider.dart';

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
    });
  }

  void _addRecipe(Recipe recipe) {
    setState(() {
      _recipes.add(recipe);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(),
          RecipeListPage(recipes: _recipes, onAdd: _addRecipe),
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

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('ホームページ'),
    );
  }
}

class RecipeListPage extends StatelessWidget {
  final List<Recipe> recipes;
  final Function(Recipe) onAdd;

  const RecipeListPage({Key? key, required this.recipes, required this.onAdd})
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

class RecipeInputPage extends StatefulWidget {
  const RecipeInputPage({Key? key}) : super(key: key); // keyパラメータを追加

  @override
  _RecipeInputPageState createState() => _RecipeInputPageState();
}

class _RecipeInputPageState extends State<RecipeInputPage> {
  final _formKey = GlobalKey<FormState>();
  String _recipeTitle = '';
  File? _recipePhoto; // File型に変更
  String _recipeDiscription = '';
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _recipePhoto = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('レシピ入力'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'レシピタイトル'),
                onSaved: (value) {
                  _recipeTitle = value!;
                },
              ),
              SizedBox(height: 20),
              _recipePhoto == null
                  ? Text('写真が選択されていません')
                  : Image.file(_recipePhoto!),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('写真を選択'),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'レシピの説明'),
                onSaved: (value) {
                  _recipeDiscription = value!;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context, {
                      'title': _recipeTitle,
                      'photo': _recipePhoto?.path,
                      'description': _recipeDiscription,
                    });
                  }
                },
                child: Text('投稿'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
