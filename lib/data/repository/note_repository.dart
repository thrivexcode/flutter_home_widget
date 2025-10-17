import 'package:flutter_thrivexcode_home_widget/data/local/app_database.dart';
import 'package:flutter_thrivexcode_home_widget/domain/models/note_model.dart';
import 'package:drift/drift.dart' as drift;

class NoteRepository {
  final AppDatabase _db;

  NoteRepository(this._db);

  /// ✅ Insert catatan baru
  Future<void> insertNote(NoteModel note) async {
    await _db.into(_db.notes).insert(
          NotesCompanion.insert(
            id: drift.Value(note.id),
            title: note.title,
            content: drift.Value(note.content),
            createdAt: drift.Value(note.createdAt),
            updatedAt: drift.Value(note.updatedAt),
          ),
        );
  }

  /// 📥 Ambil semua catatan
  Future<List<NoteModel>> getAllNotes() async {
    final rows = await _db.select(_db.notes).get();
    return rows
        .map((row) => NoteModel(
              id: row.id,
              title: row.title,
              content: row.content,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ))
        .toList();
  }

  /// ✏️ Update catatan
  Future<void> updateNote(NoteModel note) async {
    await (_db.update(_db.notes)..where((tbl) => tbl.id.equals(note.id))).write(
      NotesCompanion(
        title: drift.Value(note.title),
        content: drift.Value(note.content),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  /// 🗑️ Hapus catatan
  Future<void> deleteNote(String id) async {
    await (_db.delete(_db.notes)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// 🧭 Stream data (live update)
  Stream<List<NoteModel>> watchAllNotes() {
    return _db.select(_db.notes).watch().map(
          (rows) => rows
              .map((row) => NoteModel(
                    id: row.id,
                    title: row.title,
                    content: row.content,
                    createdAt: row.createdAt,
                    updatedAt: row.updatedAt,
                  ))
              .toList(),
        );
  }
}
