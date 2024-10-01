import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  final List<String> _ingredients = [];
  final TextEditingController _ingredientController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _recipePhoto = File(pickedFile.path);
      });
    }
  }

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text);
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 209),
      appBar: AppBar(
        title: Text('レシピ入力'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                  controller: _ingredientController,
                  decoration: InputDecoration(labelText: '材料'),
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: _addIngredient,
                  child: Text('材料を追加'),
                ),
                SizedBox(height: 16.0),
                Text('材料リスト:'),
                for (int i = 0; i < _ingredients.length; i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_ingredients[i]),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeIngredient(i),
                      ),
                    ],
                  ),
                SizedBox(height: 16.0),
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
      ),
    );
  }
}
