class Recipe {
  int id;
  String name;
  String photo;
  String description;

  Recipe({
    required this.id,
    required this.name,
    required this.photo,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'description': description,
    };
  }

  static Recipe fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      photo: map['photo'],
      description: map['description'],
    );
  }
}
