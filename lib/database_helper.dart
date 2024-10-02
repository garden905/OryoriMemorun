import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'recipe.dart';

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 4; // バージョンを更新

  static final table = 'recipes';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnPhoto = 'photo'; // photoカラムを追加
  static final columnDescription = 'description';
  static final columnIngredients = 'ingredients'; // ingredientsカラムを追加
  static final columnIsFavorite = 'isFavorite';

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
        "$columnPhoto BLOB NOT NULL, "
        "$columnDescription TEXT NOT NULL,"
        "$columnIngredients TEXT NOT NULL DEFAULT ''," // ingredientsカラムを追加
        "$columnIsFavorite INTEGER NOT NULL DEFAULT 0)"); // isFavoriteカラムを追加);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE $table ADD COLUMN $columnPhoto BLOB NOT NULL DEFAULT ''
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
      ALTER TABLE $table ADD COLUMN $columnIsFavorite INTEGER NOT NULL DEFAULT 0
    '''); // isFavoriteカラムを追加
    }
    if (oldVersion < 4) {
      await db.execute('''
      ALTER TABLE $table ADD COLUMN $columnIngredients TEXT NOT NULL DEFAULT ''
    '''); // ingredientsカラムを追加
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

  Future<void> updateFavoriteStatus(int id, bool isFavorite) async {
    Database db = await database;
    await db.update(
      table,
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'MyDatabase.db');
    await deleteDatabase(path);
  }
}
