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

  @override
  void initState() {
    super.initState();
    _recipeTitle = widget.recipe.name;
    _recipeDescription = widget.recipe.description;
    _recipePhoto = File(widget.recipe.photo);
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
