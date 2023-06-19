import 'package:balancemanagement_app/models/calendar.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/category.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
  static Database db;                // Singleton Database

  static String calendarTable = 'claendar';
  static String colId = 'id';
  static String colMoney = 'money';
  static String colTitle = 'title';
  static String colMemo = 'memo';
  static String colDate = 'date';
  static String colCategoryId = 'categoryId';

  static String categoryTable = 'category';
  static String colPlus = 'plus';

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
    final _database = await openDatabase(
      path,
      version: 3,
      onCreate: _createDb,
      onUpgrade: _updateDb,
    );
    return _database;
  }

  static void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $calendarTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colMoney REAL, $colMemo TEXT, $colDate TEXT, $colCategoryId INTEGER)');
    
    await db.execute('CREATE TABLE $categoryTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colPlus TEXT)');
    await db.insert(categoryTable,Category("売上",true).toMap());
    await db.insert(categoryTable,Category("購入",false).toMap());
    for(var i=0;i<6;i++){
      await db.insert(categoryTable,Category("その他${i+1}",true).toMap());
      await db.insert(categoryTable,Category("その他${i+1}",false).toMap());
    }
  }

  static void _updateDb(Database db, int oldVersion, int newVersion) async {

    if(Platform.isAndroid) {
      // version2は小数点 カラム変更　
      // 元のデータの名前を変更する
      await db.execute('ALTER TABLE $calendarTable RENAME hoge');
      // 新しいデータ型に変更したテーブルを作成
      await db.execute('CREATE TABLE $calendarTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
          '$colMoney REAL, $colMemo TEXT, $colDate TEXT, $colCategoryId INTEGER)');
      // データを移行する
      await db.execute('INSERT INTO $calendarTable SELECT * FROM hoge');
      // 名前の変更した元データを削除する
      await db.execute('DROP TABLE hoge');
    }

      // version3 カテゴリ移行

      getApplicationDocumentsDirectory().then((directory) async {
        // String absoluteEndPath = join(directory.path, "/category.db");
        await db.execute('ATTACH DATABASE "' + directory.path + "/category.db" + '" as sub').catchError((e) {
          print(e);
        }).whenComplete(() {
          print("ATTACH　成功");
        });

        await db.execute('CREATE TABLE main.$categoryTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colPlus TEXT)');
        // データを移行する
        await db.execute('INSERT INTO main.$categoryTable SELECT * FROM sub.$categoryTable');
        // アッタチを切る
        await db.execute('DETACH sub');
      });

      // Directory directory = await getApplicationDocumentsDirectory();
      // 外部テーブルに接続する(アタッチ)
      // await db.execute('ATTACH DATABASE "' + directory.path + "/category.db" + '" as sub').catchError((e) {
      //   print(e);
      // }).whenComplete(() {
      //   print("ATTACH　成功");
      // });
      // await db.execute('CREATE TABLE main.$categoryTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colPlus TEXT)');
      // // データを移行する
      // await db.execute('INSERT INTO main.$categoryTable SELECT * FROM sub.$categoryTable');
      // // アッタチを切る
      // await db.execute('DETACH sub');
  }

  // DBの移行（アタッチ）
  // static Future<Database> attachDb({Database db, String databaseName, String databaseAlias}) async {
  //   // 外部テーブルに接続する(アタッチ)
  //   Directory directory = await getApplicationDocumentsDirectory();
  //   String absoluteEndPath = join(directory.path, databaseName);
  //   await db.rawQuery('ATTACH DATABASE "$absoluteEndPath" as sub');
  //   // print("アタッチ完了");
  //   //
  //   // await db.rawQuery('DETACH "$databaseAlias"');
  //
  //   return db;
  // }
  // =======初期設定 END======================

  // static void _updateDb() async {
  //   await db.execute('CREATE TABLE $calendarTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
  //       '$colMoney INTEGER, $colMemo TEXT, $colDate TEXT, $colCategoryId INTEGER)');
  // }

  // Fetch Operation: データベースからすべてのカレンダーオブジェクトを取得します
  Future<List<Map<String, dynamic>>> getCalendarMonthMapList(month) async {
    final _month = DateFormat('yyyy-MM').format(month);
  //  var result = await this.database.query(calendarTable,where: '#colDate = ?', whereArgs: [_month+"%"], orderBy: '$colId ASC');
    final result = await this.database.rawQuery('SELECT * FROM $calendarTable WHERE $colDate LIKE ?', [_month + '%']);
    return result;
  }
  // Fetch Operation: データベースからすべてのカレンダーオブジェクトを取得します
  Future<List<Map<String, dynamic>>> getCalendarMapList() async {
    final result = await this.database.query(calendarTable, orderBy: '$colId ASC');
    return result;
  }
  //選択月を全て持ってくる
  Future<Map<String,dynamic>> getCalendarMonthInt(date) async {
    final _text = DateFormat('yyyy-MM').format(date);
    final result = await this.database.rawQuery('SELECT COALESCE(SUM($colMoney),0) AS SUM,'
        'COALESCE(SUM(CASE WHEN $colMoney >= 0 THEN $colMoney ELSE 0 END),0) AS PLUS,'
        'COALESCE(SUM(CASE WHEN $colMoney <  0 THEN $colMoney ELSE 0 END),0) AS MINUS '
        'FROM $calendarTable WHERE $colDate LIKE ?' ,[_text+'%']);
    return  result[0];
  }

  Future<dynamic> getCalendarYearDouble(date) async{
    var _text = DateFormat('yyyy').format(date);
    final result = await this.database.rawQuery('SELECT COALESCE(SUM($colMoney),0) AS MONEY FROM $calendarTable WHERE $colDate LIKE ?' ,[_text+'%']);
    return result[0]['MONEY'];
  }

  //選択年を全て持ってくる
  Future<Map<String,dynamic>> getCalendarYearMap(date) async{
    final _text = DateFormat('yyyy').format(date);
    final result = await this.database.rawQuery('SELECT COALESCE(SUM($colMoney),0) AS SUM,'
        'COALESCE(SUM(CASE WHEN $colMoney >= 0 THEN $colMoney ELSE 0 END),0) AS PLUS,'
        'COALESCE(SUM(CASE WHEN $colMoney <  0 THEN $colMoney ELSE 0 END),0) AS MINUS '
        'FROM $calendarTable WHERE $colDate LIKE ?' ,[_text+'%']);
    return  result[0];
  }

  /*
  * 【SELECT】 合計値
  * 使用済の料理の合計値 SUM PLUS MINUS
   */
  Future<Map> sumData(DateTime _date) async {
    String month = DateFormat('yyyy-MM').format(_date);
    Map map = {};
    final monthSum = await database.rawQuery(
        '''
          SELECT COALESCE(sum($colMoney), 0) AS MonthSUM,
          COALESCE(SUM(CASE WHEN $colMoney >= 0 THEN $colMoney ELSE 0 END),0) AS MonthPULS,
          COALESCE(SUM(CASE WHEN $colMoney <  0 THEN $colMoney ELSE 0 END),0) AS MonthNINUS 
          FROM $calendarTable
          WHERE $colDate LIKE '$month%'
        '''
    );
    String year = DateFormat('yyyy').format(_date);
    final yearSum = await database.rawQuery(
        '''
          SELECT COALESCE(sum($colMoney), 0) AS YearSUM,
          COALESCE(SUM(CASE WHEN $colMoney >= 0 THEN $colMoney ELSE 0 END),0) AS YearPULS,
          COALESCE(SUM(CASE WHEN $colMoney <  0 THEN $colMoney ELSE 0 END),0) AS YearNINUS 
          FROM $calendarTable
          WHERE $colDate LIKE '$year%'
        '''
    );
    map.addAll(monthSum[0]);
    map.addAll(yearSum[0]);
    // print(map);
    return map;
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
        FROM $calendarTable
        WHERE $colDate LIKE '$date%'
      '''
    );
    return result;
  }

  /*
  * 【SELECT】 選択日のボトムリストと金額一覧
   */
  Future<List> selectDayList(DateTime _date) async {
    String date = DateFormat('yyyy-MM-dd').format(_date);
    final result = await database.rawQuery(
        '''
  SELECT $calendarTable.* , ($categoryTable.$colTitle || $calendarTable.$colTitle) AS title
  FROM $calendarTable
  LEFT JOIN $categoryTable ON $categoryTable.id = $calendarTable.$colCategoryId
  WHERE $colDate LIKE '$date%'
      '''
    ).catchError((e) {
      print(e);
    }).whenComplete(() {
      print("ATTACH　成功");
    });
    return result;
  }
  // SELECT cal.*
  // FROM $calendarTable AS cal
  // INNER JOIN $categoryTable AS cat on cat.id = cal.$colCategoryId
  // WHERE $colDate LIKE '$date%'

  /*
  * 【SELECT】 選択した収支
   */
  Future<Calendar> selectCalendar(int id) async {
    final calendar = await this.database.query(calendarTable, where: 'id = ${id}');
    final result = Calendar.fromMapObject(calendar[0]);
    return result;
  }

//挿入　更新　削除
  // Insert Operation: Insert a Note object to database
  Future<int> insertCalendar(Calendar calendar) async {
    var result = await this.database.insert(calendarTable, calendar.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateCalendar(Calendar calendar) async {
    final result = await this.database.update(calendarTable, calendar.toMap(), where: '$colId = ?', whereArgs: [calendar.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteCalendar(int id) async {
    final result = await this.database.rawDelete('DELETE FROM $calendarTable WHERE $colId = $id');
    return result;
  }

  Future<void> allDeleteCalendar() async {
    await this.database.rawDelete('DELETE FROM $calendarTable');
  }

  //データベース内のNoteオブジェクトの数を取得します
  Future<int> getCount() async {
    //rawQuery括弧ないにSQL文が使える。
    final x = await this.database.rawQuery('SELECT COUNT (*) from $calendarTable');
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
    final sql = "select sum($colMoney) as sum, strftime('%Y-%m', $colDate) as month from $calendarTable WHERE strftime('%Y-%m', $colDate) <= '$last_month' group by month order by month desc;";
    final calendarList = await this.database.rawQuery(sql);
    return calendarList;
  }
  //プラス収支を月集計
  Future<List> getMonthListPlus(last_month) async {
    final sql = "select abs(sum($colMoney)) as sum, strftime('%Y-%m', $colDate) as month from $calendarTable where $colMoney >= 0 AND strftime('%Y-%m', $colDate) <= '$last_month' group by month order by month desc;";
    final calendarList = await this.database.rawQuery(sql);
    return calendarList;
  }
 //マイナス収支を月集計
  Future<List> getMonthListMinus(last_month) async {
    final sql = "select abs(sum($colMoney)) as sum, strftime('%Y-%m', $colDate) as month from $calendarTable where $colMoney < 0 AND strftime('%Y-%m', $colDate) <= '$last_month' group by month order by month desc;";
    final calendarList = await this.database.rawQuery(sql);
    return calendarList;
  }
}