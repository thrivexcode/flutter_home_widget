import 'package:flutter/material.dart';
import 'package:flutter_thrivexcode_home_widget/data/providers/note_provider.dart';
import 'package:flutter_thrivexcode_home_widget/domain/models/note_model.dart';
import 'package:flutter_thrivexcode_home_widget/presentation/screens/note_detail_screen.dart';
import 'package:provider/provider.dart';

class NoteCard extends StatefulWidget {
  final NoteModel note;
  final VoidCallback? onTap;
  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false; // State untuk expand/collapse preview note

  // ==================== Delete Note ====================
  void _deleteNote() {
    final provider = context.read<NoteProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.deleteNote(widget.note.id); // hapus note
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: (_) {
        // Long press → expand preview
        setState(() => _isExpanded = true);
      },
      onLongPressEnd: (_) {
        // Lepas jari → collapse preview
        setState(() => _isExpanded = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320), // Animasi smooth
        curve: Curves.easeInOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ==================== Konten Note ====================
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🧾 Title Note
                  Text(
                    note.title.isNotEmpty ? note.title : '(No title)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 📄 Content Note
                  Text(
                    note.content ?? '',
                    maxLines:
                        _isExpanded ? null : 3, // max 3 lines saat collapsed
                    overflow: _isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),

                  // 💬 Hint text saat collapsed dan konten panjang
                  if (!_isExpanded && (note.content?.length ?? 0) > 100)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Hold to preview',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ==================== Delete Button ====================
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: _deleteNote,
                splashRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
