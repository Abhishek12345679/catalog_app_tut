// constants for sqflite
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
