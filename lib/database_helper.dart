import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'recipe.dart';

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 2; // バージョンを更新

  static final table = 'recipes';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnPhoto = 'photo'; // photoカラムを追加
  static final columnDescription = 'description';

  // 無名コンストラクタの追加
  DatabaseHelper();

  // シングルトンパターン
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $table ("
        "$columnId INTEGER PRIMARY KEY, "
        "$columnName TEXT NOT NULL, "
        "$columnPhoto TEXT NOT NULL, "
        "$columnDescription TEXT NOT NULL)");
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE $table ADD COLUMN $columnPhoto TEXT NOT NULL DEFAULT ''
      ''');
    }
  }

  Future<int> insertRecipe(Recipe recipe) async {
    Database db = await database;
    return await db.insert(table, recipe.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Recipe>> queryAllRecipes() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }

  Future<int> updateRecipe(Recipe recipe) async {
    Database db = await database;
    return await db.update(table, recipe.toMap(),
        where: '$columnId = ?', whereArgs: [recipe.id]);
  }

  Future<void> clearTable() async {
    final db = await database;
    await db.execute('DELETE FROM example');
  }
}
