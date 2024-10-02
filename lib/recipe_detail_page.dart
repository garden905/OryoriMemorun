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
                  ingredients: result['ingredients'],
                  steps: result['steps'],
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
              Text(
                '材料',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: recipe.ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = recipe.ingredients[index];
                  return Text(
                    '${ingredient['ingredient']} (${ingredient['quantity']})',
                    style: TextStyle(fontSize: 16),
                  );
                },
              ),
              SizedBox(height: 16),
              Text(
                '作り方',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: recipe.steps.length,
                itemBuilder: (context, index) {
                  final step = recipe.steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${index + 1}. $step',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
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
