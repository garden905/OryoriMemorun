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
