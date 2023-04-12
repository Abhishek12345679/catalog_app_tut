// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'package:catalog_app_tut/extensions/list/filter.dart';
import 'package:catalog_app_tut/services/crud/crud_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesService {
  Database? _db;
  DatabaseUser? _user;

  List<DatabaseNote> _dbNotes = [];
  late final StreamController<List<DatabaseNote>> _dbNotesStreamController;

  // start: pattern for using a singleton in dart
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _dbNotesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _dbNotesStreamController.sink.add(_dbNotes);
      },
    );
  }
  factory NotesService() => _shared;
  // end: pattern for using a singleton in dart

  Stream<List<DatabaseNote>> get allNotes {
    return _dbNotesStreamController.stream.filter((note) {
      final currentUser = _user;
      if (currentUser != null) {
        return note.userId == currentUser.id;
      } else {
        throw UserShouldBeSetBeforeReadingAllNotes();
      }
    });
  }

  Future<void> _cacheNotes() async {
    final notes = await getAllNotes();
    _dbNotes = notes;
    _dbNotesStreamController.add(_dbNotes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote databaseNote,
    required String newText,
  }) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();

    await getNote(noteId: databaseNote.id);

    final updatesCount = await db.update(
      noteTable,
      {textColumn: newText},
      where: 'id = ?',
      whereArgs: [databaseNote.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    }

    final note = await getNote(noteId: databaseNote.id);
    _dbNotes.removeWhere((note) => note.id == databaseNote.id);

    _dbNotes.add(note);
    _dbNotesStreamController.add(_dbNotes);
    return note;
  }

  Future<List<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final allNotes = await db.query(noteTable);
    final dbNotes = allNotes.map((e) => DatabaseNote.fromRow(e)).toList();

    _dbNotes = dbNotes;
    _dbNotesStreamController.add(_dbNotes);

    return dbNotes;
  }

  Future<DatabaseNote> getNote({required int noteId}) async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [noteId],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    }

    // users.first is same as users[0], only difference being, in how they deal with errors
    final note = DatabaseNote.fromRow(notes.first);
    _dbNotes.removeWhere((note) => note.id == noteId);

    _dbNotes.add(note);
    _dbNotesStreamController.add(_dbNotes);
    return note;
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();

    final db = _getDatabaseOrThrow();
    final numOfNotesDeleted = await db.delete(noteTable);

    _dbNotes = [];
    _dbNotesStreamController.add(_dbNotes);
    return numOfNotesDeleted;
  }

  Future<void> deleteNote({required int noteId}) async {
    await _ensureDbIsOpen();

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
    } else {
      _dbNotes.removeWhere((note) => note.id == noteId);
      _dbNotesStreamController.add(_dbNotes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();

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

    final newNote = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedToCloud: false,
    );

    _dbNotes.add(newNote);
    _dbNotesStreamController.add(_dbNotes);

    return newNote;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
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

    // users.first is same as users[0], only difference being, in how they deal with errors
    return DatabaseUser.fromRow(users.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
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

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser catch (_) {
      final newUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = newUser;
      }
      return newUser;
    } catch (_) {
      // throws the exception raised by any remaining errors from getUser/create user have to be handled where `getOrCreateUser` is called.
      rethrow;
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedUserCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedUserCount == 0) {
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

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
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
      await _cacheNotes();
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
  String toString() => 'DatabaseUser, ID = $id, email = $email';

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
const userTable = "user";
const idColumn = 'id';
const userIdColumn = 'user_id';
const emailColumn = 'email';
const isSyncedToCloudColumn = 'is_synced_to_cloud';
const textColumn = 'text';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "text"	TEXT,
        "user_id"	INTEGER NOT NULL,
        "is_synced_to_cloud"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES "user"("id")
      );''';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL UNIQUE,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
