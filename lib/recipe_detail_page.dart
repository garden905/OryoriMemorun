// RecipeDetailPage.dart
import 'package:flutter/material.dart';
import 'recipe.dart';
import 'dart:io';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
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
