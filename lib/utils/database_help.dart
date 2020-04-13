import 'package:balancemanagement_app/models/calendar.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
  static Database db;                // Singleton Database

  static String tableName = 'claendar';
  static String colId = 'id';
  static String colMoney = 'money';
  static String colTitle = 'title';
  static String colMemo = 'memo';
  static String colDate = 'date';
  static String colCategoryId = 'categoryId';


  DatabaseHelper._createInstance(); // DatabaseHelperのインスタンスを作成するための名前付きコンストラクタ

  factory DatabaseHelper() {

    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance(); // これは1回だけ実行されます。
    }
    return _databaseHelper;
  }

  Database get database{
    return db;
  }

  static Future<Database> initializeDatabase() async {
    // データベースを保存するためのAndroidとiOSの両方のディレクトリパスを取得する
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'calendar.db';

    // Open/指定されたパスにデータベースを作成する
    var calendarsDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return calendarsDatabase;
  }

  static void _createDb(Database db, int newVersion) async {

    await db.execute('CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colMoney INTEGER, $colMemo TEXT, $colDate TEXT, $colCategoryId INTEGER)');
  }

  // Fetch Operation: データベースからすべてのカレンダーオブジェクトを取得します
  Future<List<Map<String, dynamic>>> getCalendarMapList() async {
//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await this.database.query(tableName, orderBy: '$colId ASC');
    return result;
  }
//挿入　更新　削除
  // Insert Operation: Insert a Note object to database
  Future<int> insertCalendar(Calendar calendar) async {
    var result = await this.database.insert(tableName, calendar.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateCalendar(Calendar calendar) async {
    var result = await this.database.update(tableName, calendar.toMap(), where: '$colId = ?', whereArgs: [calendar.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteCalendar(int id) async {
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

  // 'Map List' [List <Map>]を取得し、それを 'Calendar List' [List <Note>]に変換します
  Future<List<Calendar>> getCalendarList() async {
    //全てのデータを取得
    var calendarMapList = await getCalendarMapList(); // Get 'Map List' from database
    int count = calendarMapList.length;         // Count the number of map entries in db table

    List<Calendar> calendarList = List<Calendar>();
    for (int i = 0; i < count; i++) {
      calendarList.add(Calendar.fromMapObject(calendarMapList[i]));
    }
    return calendarList;
  }

  Future<List<Map<String, dynamic>>> getCalendarMonthMapList() async {
    var result = await this.database.query(tableName, orderBy: '$colId ASC');
    return result;
  }

  Future<List<Calendar>> getCalendarDayList(selectDay) async {
    var calendarMapList = await getCalendarDayMapList(selectDay); // Get 'Map List' from database
    int count = calendarMapList.length;         // Count the number of map entries in db table

    List<Calendar> calendarList = List<Calendar>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      calendarList.add(Calendar.fromMapObject(calendarMapList[i]));
    }
    return calendarList;
  }
  Future<List<Map<String, dynamic>>> getCalendarDayMapList(selectDay) async {
    var result = await this.database.query(tableName,where: 'date <= ?' ,whereArgs: selectDay, orderBy: '$colId ASC');
    return result;
  }
}