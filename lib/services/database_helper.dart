import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tugas_akhir/utils.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'AyangBeb.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            role TEXT
          )
        ''');
        await _insertDefaultSuperAdmin(db);
      },
    );
  }

  Future<void> _insertDefaultSuperAdmin(Database db) async {
    String username = 'superadmin@gmail.com';
    String password = hashPassword('superadminpassword');
    String role = 'super_admin';

    try {
      List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (result.isEmpty) {
        await db.insert('users', {
          'username': username,
          'password': password,
          'role': role,
        });
        print("Superadmin berhasil ditambahkan ke SQLite.");
      } else {
        print("Superadmin sudah ada di SQLite.");
      }
    } catch (e) {
      print("Error inserting default superadmin: $e");
    }
  }

  Future<void> insertUser(String username, String password, String role) async {
    final db = await database;
    try {
      await db.insert(
        'users',
        {
          'username': username,
          'password': hashPassword(password),
          'role': role,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("User $username berhasil ditambahkan ke SQLite.");
    } catch (e) {
      print("Error inserting user: $e");
    }
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      return maps.isNotEmpty ? maps.first : null;
    } catch (e) {
      print("Error retrieving user: $e");
      return null;
    }
  }

  Future<void> deleteUser(String username) async {
    final db = await database;
    try {
      await db.delete(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      print("User $username berhasil dihapus dari SQLite.");
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  Future<String?> login(String username, String password) async {
    final db = await database;

    try {
      List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, hashPassword(password)],
      );

      return result.isNotEmpty ? result.first['role'] as String : null;
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  Future<void> updateUserPassword(String username, String newPassword) async {
    final db = await database;
    try {
      await db.update(
        'users',
        {'password': hashPassword(newPassword)},
        where: 'username = ?',
        whereArgs: [username],
      );
      print("Password untuk user $username berhasil diupdate.");
    } catch (e) {
      print("Error updating password: $e");
    }
  }

  Future<void> updateUserRole(String username, String newRole) async {
    final db = await database;
    try {
      await db.update(
        'users',
        {'role': newRole},
        where: 'username = ?',
        whereArgs: [username],
      );
      print("Role untuk user $username berhasil diupdate menjadi $newRole.");
    } catch (e) {
      print("Error updating user role: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('users');
      return maps;
    } catch (e) {
      print("Error retrieving all users: $e");
      return [];
    }
  }
}
