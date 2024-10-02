import 'dart:convert';

class Recipe {
  final int id;
  final String name;
  final String photo;
  final String description;
  final List<Map<String, String>> ingredients; // 材料と個数のリスト
  bool isFavorite; // お気に入りフラグ

  Recipe({
    required this.id,
    required this.name,
    required this.photo,
    required this.description,
    required this.ingredients, // コンストラクタに追加
    this.isFavorite = false, // デフォルトはfalse
  });

  // JSONへの変換メソッドにisFavoriteを追加
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'description': description,
      'ingredients': jsonEncode(ingredients), // JSON文字列に変換
      'isFavorite': isFavorite ? 1 : 0, // SQLiteではboolをintで保存
    };
  }

  // JSONからの変換メソッドにisFavoriteを追加
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      photo: map['photo'],
      description: map['description'],
      ingredients: (jsonDecode(map['ingredients']) as List)
          .map((item) => Map<String, String>.from(item))
          .toList(), // JSON文字列からリストに変換
      isFavorite: map['isFavorite'] != null
          ? map['isFavorite'] == 1
          : false, // nullチェックを追加
    );
  }
}
