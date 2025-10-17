import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter_thrivexcode_home_widget/data/local/app_database.dart';

/// Helper untuk update Home Widget dari Drift
class NoteWidgetUpdater {
  /// Inisialisasi Home Widget (sekali di awal)
  static Future<void> init() async {
    // Pastikan ini sesuai dengan `android:appwidget.provider` di AndroidManifest.xml
    await HomeWidget.setAppGroupId('example.flutter_thrivexcode_home_widget');
    debugPrint('🟢 HomeWidget initialized with AppGroupId');
  }

  /// ==================== Update 3 Note Terbaru ====================
  /// Ambil note terbaru dari Drift lalu simpan ke HomeWidget
  static Future<void> updateLatestNotesFromDrift(AppDatabase db) async {
    try {
      // Query 3 note terbaru berdasarkan createdAt descending
      final latestNotes = await (db.select(db.notes)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(3))
          .get();

      // Jika kosong, kirim placeholder ke widget
      if (latestNotes.isEmpty) {
        debugPrint(
            '⚠️ Tidak ada catatan di Drift, kirim placeholder ke widget');
        await _updateWidgetWithData([]);
        return;
      }

      // Simpan note terbaru ke widget
      await _updateWidgetWithData(latestNotes);
    } catch (e) {
      debugPrint('❌ Gagal mengambil data dari Drift: $e');
    }
  }

  /// ==================== Simpan Data ke HomeWidget ====================
  /// Hanya private method
  static Future<void> _updateWidgetWithData(List<Note> notes) async {
    // Bersihkan semua data lama
    for (var i = 1; i <= 3; i++) {
      await HomeWidget.saveWidgetData('note_id_$i', '');
      await HomeWidget.saveWidgetData('note_title_$i', '');
      await HomeWidget.saveWidgetData('note_content_$i', '');
    }

    // Simpan data terbaru ke SharedPreferences / AppGroup
    for (var i = 0; i < notes.length && i < 3; i++) {
      final note = notes[i];

      // 🆔 Simpan ID asli note dari Drift
      await HomeWidget.saveWidgetData('note_id_${i + 1}', note.id);

      // Validasi title & content → beri default jika kosong
      final title =
          note.title.trim().isNotEmpty == true ? note.title.trim() : 'Untitled';
      final content = note.content?.trim().isNotEmpty == true
          ? note.content!.trim()
          : 'No content';

      await HomeWidget.saveWidgetData('note_title_${i + 1}', title);
      await HomeWidget.saveWidgetData('note_content_${i + 1}', content);

      debugPrint(
          '🧩 Saved in SharedPrefs: note_title_${i + 1}="$title", note_content_${i + 1}="$content"');
    }


    // Trigger update widget di Android
    await HomeWidget.updateWidget(
      name: 'MyNotesWidgetProvider',
      iOSName: 'MyNotesWidget',
    );
    debugPrint('🔁 HomeWidget.updateWidget() triggered ✅');
  }

  /// ==================== Manual Refresh ====================
  /// Bisa dipanggil dari tombol refresh di app UI
  static Future<void> onRefresh(BuildContext context, AppDatabase db) async {
    await updateLatestNotesFromDrift(db);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Widget refreshed successfully ✅')),
      );
    }
  }
}
