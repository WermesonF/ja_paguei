import 'package:ja_paguei/models/expense.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ExpenseHelper {
  ExpenseHelper._();
  static final ExpenseHelper instance = ExpenseHelper._();
  static Database? _db;

  final String table = 'EXPENSE_TABLE';
  final String idColumn = 'ID';
  final String titleColumn = 'TITLE';
  final String costColumn = 'COST';
  final String dateColumn = 'DATE';

  get db async {
    if (_db != null) return _db;

    return await _initDb();
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "japaguei.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $table($idColumn INTEGER PRIMARY KEY, $titleColumn  TEXT, $costColumn REAL, $dateColumn TEXT)");
    });
  }

  Future<Expense> saveExpense(Expense expense) async {
    final Database dbExpense = await db;
    expense.id = await dbExpense.insert(table, expense.toMap());
    return expense;
  }

  Future<Expense?> getExpense(int id) async {
    final Database dbExpense = await db;
    List<Map> maps = await dbExpense.query(table,
        columns: [idColumn, titleColumn, costColumn, dateColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteExpense(int? id) async {
    final Database dbExpense = await db;
    return await dbExpense
        .delete(table, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateExpense(Expense expense) async {
    Database dbExpense = await db;
    return await dbExpense.update(table, expense.toMap(),
        where: "$idColumn = ?", whereArgs: [expense.id]);
  }

  Future<List<Expense>> getAllExpense() async {
    final Database dbExpense = await db;
    List<Map<String, dynamic>> maps = await dbExpense.query(table);

    return List.generate(maps.length, (index) {
      return Expense.fromMap(maps[index]);
    });
  }

  Future<int> deleteAll() async {
    final Database dbExpense = await db;
    return await dbExpense.rawDelete("DELETE FROM $table");
  }

  Future close() async {
    final Database dbExpense = await db;
    dbExpense.close();
  }
}
