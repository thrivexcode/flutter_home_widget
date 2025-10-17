import 'package:flutter/material.dart';
import 'package:flutter_thrivexcode_home_widget/data/local/app_database.dart';
import 'package:flutter_thrivexcode_home_widget/data/repository/note_repository.dart';
import 'package:flutter_thrivexcode_home_widget/domain/models/note_model.dart';
import 'package:uuid/uuid.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;

  // ==================== State ====================
  List<NoteModel> _notes = []; // Data note saat ini
  List<NoteModel> get notes => _notes; // Getter agar UI bisa akses notes

  bool _isLoading = false; // State loading untuk fetch data
  bool get isLoading => _isLoading;

  // ==================== Constructor ====================
  NoteProvider(AppDatabase db) : _repository = NoteRepository(db) {
    // Load note pertama kali saat provider dibuat
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await _repository.getAllNotes();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(String title, String? content) async {
    final newNote = NoteModel(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.insertNote(newNote);
    _notes.add(newNote);
    notifyListeners();
  }

  Future<void> updateNote(NoteModel updated) async {
    await _repository.updateNote(updated);
    final index = _notes.indexWhere((n) => n.id == updated.id);
    if (index != -1) {
      _notes[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    await _repository.deleteNote(id);
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadNotes();
  }

  NoteModel? getNoteById(String id) {
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }
}
