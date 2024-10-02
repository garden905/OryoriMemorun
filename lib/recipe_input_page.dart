import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

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
  List<Map<String, String>> _ingredients = []; // 材料と個数のリスト
  final TextEditingController _ingredientController = TextEditingController();
  final _quantityController = TextEditingController(); // 個数入力用のコントローラ
  List<String> _steps = ['']; // 初期状態で1つの空のステップを追加

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _recipePhoto = File(pickedFile.path);
      });
    }
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text;
    final quantity = _quantityController.text;
    if (ingredient.isNotEmpty && quantity.isNotEmpty) {
      setState(() {
        _ingredients.add({'ingredient': ingredient, 'quantity': quantity});
        _ingredientController.clear();
        _quantityController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addStep() {
    // すべてのステップが空でないことを確認
    if (_steps.every((step) => step.isNotEmpty)) {
      setState(() {
        _steps.add('');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('全ての作り方を入力してください')),
      );
    }
  }

  void _removeStep(int index) {
    setState(() {
      if (_steps.length > 1) {
        _steps.removeAt(index);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('少なくとも1つの作り方を残してください')),
        );
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _steps.removeAt(oldIndex);
      _steps.insert(newIndex, item);
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ingredientController,
                        decoration: InputDecoration(labelText: '材料'),
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 100,
                      child: TextField(
                        controller: _quantityController,
                        decoration: InputDecoration(labelText: '個数'),
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _addIngredient,
                  child: Text('材料を追加'),
                ),
                SizedBox(height: 16),
                Text(
                  '材料リスト',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = _ingredients[index];
                    return ListTile(
                      title: Text(
                          '${ingredient['ingredient']} (${ingredient['quantity']})'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeIngredient(index),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  '作り方',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Container(
                  height: 400, // 必要に応じて高さを調整
                  child: ReorderableListView(
                    onReorder: _onReorder,
                    children: List.generate(
                      _steps.length,
                      (index) {
                        return ListTile(
                          key: ValueKey(_steps[index]),
                          title: Row(
                            children: [
                              Text('${index + 1}. '),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _steps[index],
                                  onChanged: (value) {
                                    _steps[index] = value;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _removeStep(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.drag_handle),
                                onPressed: () {}, // ドラッグハンドルとして機能
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addStep,
                  child: const Text('作り方を追加'),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'レシピの説明'),
                  onSaved: (value) {
                    _recipeDiscription = value!;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.pop(context, {
                        'title': _recipeTitle,
                        'photo': _recipePhoto?.path,
                        'description': _recipeDiscription,
                        'ingredients': _ingredients,
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
