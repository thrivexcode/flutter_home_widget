import 'package:flutter/material.dart';
import 'package:flutter_thrivexcode_home_widget/data/local/app_database.dart';
import 'package:flutter_thrivexcode_home_widget/data/providers/note_provider.dart';
import 'package:flutter_thrivexcode_home_widget/domain/models/note_model.dart';
import 'package:flutter_thrivexcode_home_widget/presentation/widgets/action_icon.dart';
import 'package:flutter_thrivexcode_home_widget/presentation/widgets/note_widget_updater.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteModel? note; // jika null -> mode create, jika ada -> mode edit
  const NoteDetailScreen({super.key, this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool _isSaving = false; // State loading saat menyimpan note

  late final TextEditingController _titleController; // Controller untuk title
  late final TextEditingController _noteController; // Controller untuk content

  bool get isEditing => widget.note != null; // Cek mode edit

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      // Mode edit (dari /note/:noteId)
      _titleController = TextEditingController(text: widget.note!.title);
      _noteController = TextEditingController(text: widget.note!.content ?? '');
    } else {
      // Mode create (dari /note/new)
      _titleController = TextEditingController();
      _noteController = TextEditingController();
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _noteController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note is empty. Nothing to save.')),
      );
      return;
    }

    setState(() => _isSaving = true); // Show loading indicator
    try {
      final provider = context.read<NoteProvider>();
      final db = context.read<AppDatabase>();

      NoteModel savedNote;

      if (isEditing) {
        // ✏️ Update note
        final updated = widget.note!.copyWith(
          title: title,
          content: content.isEmpty ? null : content,
          updatedAt: DateTime.now(),
        );
        await provider.updateNote(updated);
        savedNote = updated;
      } else {
        // 🆕 Tambah note baru
        await provider.addNote(title, content.isEmpty ? null : content);
        savedNote =
            provider.notes.last; // Ambil note terakhir yang baru ditambahkan
      }

      // ✅ Update Home Widget agar tampil note terbaru langsung dari Drift
      await NoteWidgetUpdater.updateLatestNotesFromDrift(db);

      if (!mounted) return;
      context.pop();
    } catch (e, st) {
      debugPrint('❌ Error saving note: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();

    // Jika mode edit tapi note null karena masih loading
    if (isEditing && widget.note == null && noteProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Jika mode edit tapi note tetap null setelah load selesai
    if (isEditing && widget.note == null && !noteProvider.isLoading) {
      return const Scaffold(
        body: Center(child: Text('Note not found')),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        // Tombol back
        leading: IconButton(
          icon: const Icon(
            PhosphorIconsDuotone.arrowLeft,
            color: Colors.black87,
          ),
          onPressed: _handleBack,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            // Tombol simpan / loading
            child: _isSaving
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ActionIcon(
                    config: ActionIconConfig(
                      icon: PhosphorIconsDuotone.floppyDisk,
                      onTap: _saveNote,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📝 Title Field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),

            // ✍️ Note Field (Multi-line)
            Expanded(
              child: TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  hintText: 'Write your note...',
                  hintStyle: TextStyle(color: Colors.black45),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
