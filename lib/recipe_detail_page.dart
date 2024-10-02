// RecipeDetailPage.dart
import 'package:flutter/material.dart';
import 'recipe.dart';
import 'dart:io';
import 'recipe_edit_page.dart';
import 'database_helper.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 209),
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeEditPage(recipe: recipe),
                ),
              );

              if (result != null) {
                final updatedRecipe = Recipe(
                  id: result['id'],
                  name: result['title'],
                  photo: result['photo'],
                  description: result['description'],
                );
                final dbHelper = DatabaseHelper();
                await dbHelper.updateRecipe(updatedRecipe);
                // 必要に応じて状態を更新するコードを追加
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Image.file(File(recipe.photo)),
              SizedBox(height: 16),
              Text(recipe.description),
              // Add more details as needed
            ],
          ),
        ),
      ),
    );
  }
}
