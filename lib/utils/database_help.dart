import 'package:balancemanagement_app/models/calendar.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
  static Database _database;                // Singleton Database

  String tableName = 'claendar';
  String colId = 'id';
  String colMoney = 'money';
  String colTitle = 'title';
  String colMemo = 'memo';
  String colDate = 'date';


  DatabaseHelper._createInstance(); // DatabaseHelperのインスタンスを作成するための名前付きコンストラクタ

  factory DatabaseHelper() {

    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance(); // これは1回だけ実行されます。
    }
    return _databaseHelper;
  }

  Future<Database> get database async {

    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // データベースを保存するためのAndroidとiOSの両方のディレクトリパスを取得する
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'calendar.db';

    // Open/指定されたパスにデータベースを作成する
    var calendarsDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return calendarsDatabase;
  }

  void _createDb(Database db, int newVersion) async {

    await db.execute('CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colMoney INTEGER, $colMemo TEXT, $colDate TEXT)');
  }

  // Fetch Operation: データベースからすべてのカレンダーオブジェクトを取得します
  Future<List<Map<String, dynamic>>> getCalendarMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(tableName, orderBy: '$colId ASC');
    return result;
  }
//挿入　更新　削除
  // Insert Operation: Insert a Note object to database
  Future<int> insertCalendar(Calendar calendar) async {
    Database db = await this.database;
    var result = await db.insert(tableName, calendar.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateCalendar(Calendar calendar) async {
    var db = await this.database;
    var result = await db.update(tableName, calendar.toMap(), where: '$colId = ?', whereArgs: [calendar.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteCalendar(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $tableName WHERE $colId = $id');
    return result;
  }

  //データベース内のNoteオブジェクトの数を取得します
  Future<int> getCount() async {
    Database db = await this.database;
    //rawQuery括弧ないにSQL文が使える。
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $tableName');
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
//月のDB引き出す
  Future<List<Calendar>> getCalendarmonthList() async {
    var calendarMapList = await getCalendarMonthMapList(); // Get 'Map List' from database
    int count = calendarMapList.length;         // Count the number of map entries in db table

    List<Calendar> calendarList = List<Calendar>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      calendarList.add(Calendar.fromMapObject(calendarMapList[i]));
    }
    return calendarList;
  }
  Future<List<Map<String, dynamic>>> getCalendarMonthMapList() async {
    Database db = await this.database;
    var result = await db.query(tableName, orderBy: '$colId ASC');
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
    Database db = await this.database;
    var result = await db.query(tableName,where: 'date <= ?' ,whereArgs: selectDay, orderBy: '$colId ASC');
    return result;
  }
}