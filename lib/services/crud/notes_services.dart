import 'package:flutter/foundation.dart';
import 'package:pvtnotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    //make sure note exists
    await getNote(id: note.id);
    //update the note
    final updatedCount = await db.update(
      notesTable,
      {textColumn: text, isSyncedWithCloudColumn: 0},
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (updatedCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);
    final result = notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
    return result;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      return DatabaseNote.fromRow(notes.first);
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(notesTable);
    return deletedCount;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      //this delete returns no. of rows affected so in this case if row is deleted deletedcount will become 1.
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    //make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }
    //create the note
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      textColumn: '',
      isSyncedWithCloudColumn: 1,
    });
    return DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: '',
      isSyncedWithCloud: true,
    );
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      usersTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      usersTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final id = await db.insert(usersTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(id: id, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      usersTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
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
      //creates user Table
      await db.execute(createUserTable);
      //creates Notes Table
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      email = map[emailColumn] as String;
  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      text = map[textColumn] as String,
      isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1
          ? true
          : false;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';
  @override
  operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

//Constants:

const dbName = 'notes.db';
const notesTable = 'notes';
const usersTable = 'users';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

const createUserTable = '''CREATE TABLE "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);''';

const createNoteTable = '''CREATE TABLE "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"Text"	TEXT,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
''';
