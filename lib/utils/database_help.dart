import 'package:balancemanagement_app/models/calendar.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
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
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper;
  }

  Database get database{
    return db;
  }

  static Future<Database> initializeDatabase() async {
    // データベースを保存するためのAndroidとiOSの両方のディレクトリパスを取得する
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path + '/calendar.db';

    // Open/指定されたパスにデータベースを作成する
    final calendarsDatabase = await openDatabase(path, version: 1, onCreate: _createDb,
        // onUpgrade:(Database db, int oldVersion, int newVersion) async {
        //   await db.execute("ALTER TABLE memo ADD COLUMN create_at TIMESTAMP DEFAULT (datetime(CURRENT_TIMESTAMP,'localtime'));");
        // }
    );
    return calendarsDatabase;
  }

  static void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colMoney REAL, $colMemo TEXT, $colDate TEXT, $colCategoryId INTEGER)');
  }

  // static void _updateDb() async {
  //   await db.execute('CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
  //       '$colMoney INTEGER, $colMemo TEXT, $colDate TEXT, $colCategoryId INTEGER)');
  // }

  // Fetch Operation: データベースからすべてのカレンダーオブジェクトを取得します
  Future<List<Map<String, dynamic>>> getCalendarMonthMapList(month) async {
    final _month = DateFormat('yyyy-MM').format(month);
  //  var result = await this.database.query(tableName,where: '#colDate = ?', whereArgs: [_month+"%"], orderBy: '$colId ASC');
    final result = await this.database.rawQuery('SELECT * FROM $tableName WHERE $colDate LIKE ?', [_month + '%']);
    return result;
  }
  // Fetch Operation: データベースからすべてのカレンダーオブジェクトを取得します
  Future<List<Map<String, dynamic>>> getCalendarMapList() async {
    final result = await this.database.query(tableName, orderBy: '$colId ASC');
    return result;
  }
  //選択月を全て持ってくる
  Future<Map<String,dynamic>> getCalendarMonthInt(date) async {
    final _text = DateFormat('yyyy-MM').format(date);
    final result = await this.database.rawQuery('SELECT COALESCE(SUM($colMoney),0) AS SUM,'
        'COALESCE(SUM(CASE WHEN $colMoney >= 0 THEN $colMoney ELSE 0 END),0) AS PLUS,'
        'COALESCE(SUM(CASE WHEN $colMoney <  0 THEN $colMoney ELSE 0 END),0) AS MINUS '
        'FROM $tableName WHERE $colDate LIKE ?' ,[_text+'%']);
    return  result[0];
  }

  Future<dynamic> getCalendarYearDouble(date) async{
    var _text = DateFormat('yyyy').format(date);
    final result = await this.database.rawQuery('SELECT COALESCE(SUM($colMoney),0) AS MONEY FROM $tableName WHERE $colDate LIKE ?' ,[_text+'%']);
    return result[0]['MONEY'];
  }

  //選択年を全て持ってくる
  Future<Map<String,dynamic>> getCalendarYearMap(date) async{
    final _text = DateFormat('yyyy').format(date);
    final result = await this.database.rawQuery('SELECT COALESCE(SUM($colMoney),0) AS SUM,'
        'COALESCE(SUM(CASE WHEN $colMoney >= 0 THEN $colMoney ELSE 0 END),0) AS PLUS,'
        'COALESCE(SUM(CASE WHEN $colMoney <  0 THEN $colMoney ELSE 0 END),0) AS MINUS '
        'FROM $tableName WHERE $colDate LIKE ?' ,[_text+'%']);
    return  result[0];
  }

  /*
  * 【SELECT】 その日の合計値
  * 使用済の料理の合計値 SUM PLUS MINUS
   */
  Future<List> sumPriceOfDay(DateTime _date) async {
    String date = DateFormat('yyyy-MM-dd').format(_date);
    final result = await database.rawQuery(
        '''
        SELECT sum($colMoney) AS SUM,
        COALESCE(SUM(CASE WHEN $colMoney >= 0 THEN $colMoney ELSE 0 END),0) AS PLUS,
        COALESCE(SUM(CASE WHEN $colMoney <  0 THEN $colMoney ELSE 0 END),0) AS MINUS 
        FROM $tableName
        WHERE $colDate LIKE '$date%'
      '''
    );
    return result;
  }

  /*
  * 【SELECT】 選択日のリストと金額一覧
   */
  Future<List> selectDayList(DateTime _date) async {
    String date = DateFormat('yyyy-MM-dd').format(_date);
    final result = await database.rawQuery(
        '''
        SELECT * FROM $tableName
        WHERE $colDate LIKE '$date%'
      '''
    );
    return result;
  }

  /*
  * 【SELECT】 選択した収支
   */
  Future<Calendar> selectCalendar(int id) async {
    final calendar = await this.database.query(tableName, where: 'id = ${id}');
    final result = Calendar.fromMapObject(calendar[0]);
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
    final result = await this.database.update(tableName, calendar.toMap(), where: '$colId = ?', whereArgs: [calendar.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteCalendar(int id) async {
    final result = await this.database.rawDelete('DELETE FROM $tableName WHERE $colId = $id');
    return result;
  }

  Future<void> allDeleteCalendar() async {
    await this.database.rawDelete('DELETE FROM $tableName');
  }

  //データベース内のNoteオブジェクトの数を取得します
  Future<int> getCount() async {
    //rawQuery括弧ないにSQL文が使える。
    final x = await this.database.rawQuery('SELECT COUNT (*) from $tableName');
    //firstIntValueはlist型からint型に変更している。
    final result = Sqflite.firstIntValue(x);
    return result;
  }

  // 'Map List' [List <Map>]を取得し、それを 'Calendar List' [List <Note>]に変換します
  Future<List<Calendar>> getCalendarList() async {
    //全てのデータを取得
    final calendarMapList = await getCalendarMapList(); // Get 'Map List' from database
    final int count = calendarMapList.length;         // Count the number of map entries in db table

    final List<Calendar> calendarList = [];
    for (var i = 0; i < count; i++) {
      calendarList.add(Calendar.fromMapObject(calendarMapList[i]));
    }
    return calendarList;
  }

  Future<List> getMonthList(last_month) async {
    final sql = "select sum($colMoney) as sum, strftime('%Y-%m', $colDate) as month from $tableName WHERE strftime('%Y-%m', $colDate) <= '$last_month' group by month order by month desc;";
    final calendarList = await this.database.rawQuery(sql);
    return calendarList;
  }
  //プラス収支を月集計
  Future<List> getMonthListPlus(last_month) async {
    final sql = "select abs(sum($colMoney)) as sum, strftime('%Y-%m', $colDate) as month from $tableName where $colMoney >= 0 AND strftime('%Y-%m', $colDate) <= '$last_month' group by month order by month desc;";
    final calendarList = await this.database.rawQuery(sql);
    return calendarList;
  }
 //マイナス収支を月集計
  Future<List> getMonthListMinus(last_month) async {
    final sql = "select abs(sum($colMoney)) as sum, strftime('%Y-%m', $colDate) as month from $tableName where $colMoney < 0 AND strftime('%Y-%m', $colDate) <= '$last_month' group by month order by month desc;";
    final calendarList = await this.database.rawQuery(sql);
    return calendarList;
  }
}