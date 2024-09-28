class Recipe {
  final int? id;
  final String name;
  final String photo; // photoフィールドを追加

  Recipe({this.id, required this.name, required this.photo});

  // データベースに保存するためにMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo': photo, // photoを追加
    };
  }

  // データベースから読み込むためにMapから変換
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      photo: map['photo'], // photoを追加
    );
  }
}
