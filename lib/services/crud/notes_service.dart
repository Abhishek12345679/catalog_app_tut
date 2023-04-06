// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectoryException implements Exception {}

class DatabaseIsNotOpenException implements Exception {}

class CouldNotDeleteUserException implements Exception {}

class UserAlreadyExistsException implements Exception {}

class MoreThanOneUserFoundWithTheSameEmail implements Exception {}

class CouldNotFindUser implements Exception {}

class NoteDoesNotExist implements Exception {}

class CouldNotDeleteNote implements Exception {}

class NotesService {
  Database? _db;

  Future<void> deleteNote({required int noteId}) async {
    final db = _getDatabaseOrThrow();

    final note = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [noteId],
    );

    if (note.isEmpty) {
      throw NoteDoesNotExist();
    }

    final deletedNoteCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [noteId],
    );

    if (deletedNoteCount != 1) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the db with correct id
    final user = await getUser(email: owner.email);
    if (user != owner) {
      throw CouldNotFindUser();
    }

    const text = "";

    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedToCloudColumn: 0,
    });
    return DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedToCloud: false,
    );
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final users = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (users.isEmpty) {
      throw CouldNotFindUser();
    }

    // if (users.length > 1) {
    // throw MoreThanOneUserFoundWithTheSameEmail();
    // }

    // users.first is same as users[0], only difference being, in how they deal with errors
    return DatabaseUser.fromRow(users.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final userId = await db.insert(
      userTable,
      {emailColumn: email.toLowerCase()},
    );

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedUserCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedUserCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    }
    return db;
  }

  Future<void> close() async {
    final db = _getDatabaseOrThrow();
    await db.close();
    _db = null;
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);

      _db = db;

      // create user table
      await db.execute(createUserTable);

      // create note table
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException catch (_) {
      throw UnableToGetDocumentsDirectoryException();
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

  // functions that are needed to be overriden by default
  @override
  String toString() =>
      'Note,id: $id, userId:$userId, isSyncedToColumn:$isSyncedToCloud, note:$text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// constants
const dbName = "notes.db";
const noteTable = "note";
const userTable = "table";
const idColumn = 'id';
const userIdColumn = 'user_id';
const emailColumn = ' email';
const isSyncedToCloudColumn = 'is_synced_to_cloud';
const textColumn = 'text';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "text"	TEXT,
        "user_id"	INTEGER NOT NULL,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES "user"("id")
      );''';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL UNIQUE,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
