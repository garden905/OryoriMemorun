import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'recipe.dart';

class RecipeEditPage extends StatefulWidget {
  final Recipe recipe;

  RecipeEditPage({required this.recipe});

  @override
  _RecipeEditPageState createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends State<RecipeEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _recipeTitle;
  late String _recipeDescription;
  File? _recipePhoto;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _ingredients = [];
  List<String> _steps = [];

  @override
  void initState() {
    super.initState();
    _recipeTitle = widget.recipe.name;
    _recipeDescription = widget.recipe.description;
    _recipePhoto = File(widget.recipe.photo);
    _ingredients = widget.recipe.ingredients; // ここで材料リストを初期化
    _steps = widget.recipe.steps; // ここでステップリストを初期化
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _recipePhoto = File(pickedFile.path);
      });
    }
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'id': widget.recipe.id,
        'title': _recipeTitle,
        'photo': _recipePhoto?.path,
        'description': _recipeDescription,
        'ingredients': _ingredients,
        'steps': _steps,
      });
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add({'name': '', 'quantity': ''});
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addStep() {
    setState(() {
      _steps.add('');
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 209),
      appBar: AppBar(
        title: Text('レシピ編集'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveRecipe,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: _recipeTitle,
                  decoration: InputDecoration(labelText: 'レシピタイトル'),
                  onSaved: (value) {
                    _recipeTitle = value!;
                  },
                ),
                SizedBox(height: 16),
                Text('材料',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _ingredients[index]['name'],
                            decoration: InputDecoration(labelText: '材料名'),
                            onSaved: (value) {
                              _ingredients[index]['name'] = value!;
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: _ingredients[index]['quantity'],
                            decoration: InputDecoration(labelText: '個数'),
                            onSaved: (value) {
                              _ingredients[index]['quantity'] = value!;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removeIngredient(index),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addIngredient,
                  child: Text('材料を追加'),
                ),
                SizedBox(height: 16),
                Text('手順',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _steps[index],
                            decoration: InputDecoration(labelText: '手順'),
                            onSaved: (value) {
                              _steps[index] = value!;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removeStep(index),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addStep,
                  child: Text('手順を追加'),
                ),
                TextFormField(
                  initialValue: _recipeDescription,
                  decoration: InputDecoration(labelText: 'レシピ説明'),
                  onSaved: (value) {
                    _recipeDescription = value!;
                  },
                ),
                SizedBox(height: 16.0),
                _recipePhoto != null
                    ? Image.file(_recipePhoto!)
                    : Text('写真が選択されていません'),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('写真を選択'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
