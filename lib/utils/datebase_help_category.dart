
import 'package:balancemanagement_app/models/category.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelperCategory {

  static DatabaseHelperCategory _databaseHelper;    // Singleton DatabaseHelper
  static Database db;             // Singleton Database

  static String tableName = 'category';
  static String colId = 'id';
  static String colTitle = 'title';
  static String colPlus = 'plus';

  DatabaseHelperCategory._createInstance(); // DatabaseHelperのインスタンスを作成するための名前付きコンストラクタ

  factory DatabaseHelperCategory() {

    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelperCategory._createInstance(); // これは1回だけ実行されます。
    }
    return _databaseHelper;
  }

  Database get database{
    return db;
  }

  static Future<Database> initializeDatabase() async {
    // データベースを保存するためのAndroidとiOSの両方のディレクトリパスを取得する
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'category.db';

    // Open/指定されたパスにデータベースを作成する
    var categoriesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return categoriesDatabase;
  }
  static void _createDb(Database db, int newVersion) async {

    await db.execute('CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colPlus TEXT)');

    await db.insert(tableName,Category("売上",true).toMap());
    await db.insert(tableName,Category("購入",false).toMap());
    for(var i=0;i<6;i++){
      await db.insert(tableName,Category("その他${i+1}",true).toMap());
      await db.insert(tableName,Category("その他${i+1}",false).toMap());
    }
  }
  // Fetch Operation: データベースからすべてのカレンダーオブジェクトを取得します
  Future<List<Map<String, dynamic>>> getCategoryMapList() async {
//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await this.database.query(tableName, orderBy: '$colId ASC');
    return result;
  }
  //
  Future<List<Map<String, dynamic>>> getCategoryMapWhere(id) async {
    var result = await this.database.rawQuery('SELECT * FROM $tableName WHERE id = ?', [id]);
    return result;
  }
  //idと同じデータを持ってくる。
  Future <Category> getCategoryId(value) async {
    var categoryMapList = await getCategoryMapWhere(value); // Get 'Map List' from database
    return Category.fromMapObject(categoryMapList[0]);
  }

//挿入　更新　削除
  // Insert Operation: Insert a Note object to database
  Future<int> insertCategory(Category category) async {
    var result = await this.database.insert(tableName, category.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateCategory(Category category) async {
    var result = await this.database.update(tableName, category.toMap(), where: '$colId = ?', whereArgs: [category.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteCategory(int id) async {
    int result = await this.database.rawDelete('DELETE FROM $tableName WHERE $colId = $id');
    return result;
  }



  //データベース内のNoteオブジェクトの数を取得します
  Future<int> getCount() async {
    //rawQuery括弧ないにSQL文が使える。
    List<Map<String, dynamic>> x = await this.database.rawQuery('SELECT COUNT (*) from $tableName');
    //firstIntValueはlist型からint型に変更している。
    int result = Sqflite.firstIntValue(x);
    return result;
  }
  Future<List<Category>> getCategoryListAll() async {
    //全てのデータを取得
    var categoryMapList = await getCategoryMapList(); // Get 'Map List' from database
    int count = categoryMapList.length;         // Count the number of map entries in db table

    List<Category> categoryList = List<Category>();
    for (int i = 0; i < count; i++) {
        categoryList.add(Category.fromMapObject(categoryMapList[i]));
    }
    return categoryList;
  }
  //カテゴリーリストで収支毎の値を取得する。
  Future<List<Category>> getCategoryList(value) async {
    //全てのデータを取得
    var categoryMapList = await getCategoryMapList(); // Get 'Map List' from database
    int count = categoryMapList.length;         // Count the number of map entries in db table

    List<Category> categoryList = List<Category>();

    for (int i = 0; i < count; i++) {
      if(categoryMapList[i]['plus'] == value.toString()){
        categoryList.add(Category.fromMapObject(categoryMapList[i]));
      }
    }
    return categoryList;
  }

}