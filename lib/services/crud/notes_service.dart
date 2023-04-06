// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesService {
  Database? _db;

  Future<void> open() async {
    if (_db != null) {
      throw Exception();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);

      _db = db;

      // create user table
      const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL UNIQUE,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';

      await db.execute(createUserTable);

      // create note table

      const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "text"	TEXT,
        "user_id"	INTEGER NOT NULL,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES "user"("id")
      );''';

      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException catch (e) {
      log(e.message);
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedToCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedToCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        isSyncedToCloud =
            (map[isSyncedToCloudColumn] as int) == 1 ? true : false,
        text = map[textColumn] as String;

  @override
  String toString() =>
      'Note,id: $id, userId:$userId, isSyncedToColumn:$isSyncedToCloud, note:$text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = "notes.db";
const noteTable = "note";
const userTable = "table";
const idColumn = 'id';
const userIdColumn = 'user_id';
const emailColumn = ' email';
const isSyncedToCloudColumn = 'is_synced_to_cloud';
const textColumn = 'text';
