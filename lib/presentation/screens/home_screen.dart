import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_thrivexcode_home_widget/data/providers/note_provider.dart';
import 'package:flutter_thrivexcode_home_widget/presentation/widgets/empty_state.dart';
import 'package:flutter_thrivexcode_home_widget/presentation/widgets/mini_fab.dart';
import 'package:flutter_thrivexcode_home_widget/presentation/widgets/note_card.dart';
import 'package:flutter_thrivexcode_home_widget/presentation/widgets/top_action_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

//Model internal untuk menyimpan info mini FAB (title + icon)
class _PageData {
  final String title;
  final IconData icon;

  _PageData(this.title, this.icon);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // State untuk menentukan apakah FAB utama sedang terbuka
  bool _isExpanded = false;

  // Controller animasi FAB mini
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  // Data mini FAB (Text, List, Drawing, Image, Audio)
  late final List<_PageData> _pages = [
    _PageData('Text', PhosphorIconsDuotone.textAa),
    _PageData('List', PhosphorIconsDuotone.checkSquare),
    _PageData('Drawing', PhosphorIconsDuotone.paintBrush),
    _PageData('Image', PhosphorIconsRegular.image),
    _PageData('Audio', PhosphorIconsRegular.microphone),
  ];

  @override
  void initState() {
    super.initState();

    // Inisialisasi controller animasi
    _controller = AnimationController(
      duration: const Duration(milliseconds: 520), // durasi animasi
      vsync: this,
    );

    // Animasi dengan kurva easeOut saat expand, easeInOut saat collapse
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInOutCubicEmphasized,
    );
  }

  // Fungsi toggle FAB utama
  void _toggleFab() {
    if (_isExpanded) {
      _controller.reverse(); // collapse animasi
    } else {
      _controller.forward(); // expand animasi
    }
    setState(() => _isExpanded = !_isExpanded); // update UI
  }

  @override
  void dispose() {
    _controller.dispose(); // Hapus controller saat widget dihancurkan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reversedPages = _pages.reversed.toList();
    final provider = context.watch<NoteProvider>();
    final notes = provider.notes;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 📝 List Notes
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 72.0),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notes.isEmpty
                      ? const EmptyState() // Widget ketika notes kosong
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: NoteCard(
                                note: note,
                                onTap: () {
                                  context.push('/note/${note.id}');
                                },
                              ),
                            );
                          },
                        ),
            ),
          ),

          // 🌟 Top bar (Google Notes style)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: const TopActionBar(),
            ),
          ),

          // 🌫 Overlay background when expanded
          IgnorePointer(
            ignoring: !_isExpanded,
            child: AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                final opacity = _expandAnimation.value * 0.45;
                return Opacity(
                  opacity: opacity,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: 4 * _expandAnimation.value,
                        sigmaY: 4 * _expandAnimation.value),
                    child: Container(
                      color: Colors.black.withValues(alpha: opacity),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // 🟢 Floating Buttons area
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SafeArea(
        minimum: const EdgeInsets.only(bottom: 12),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 🎬 Mini FAB Animations (staggered)
              ...reversedPages.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                // Staggered effect
                final start = index * 0.06;
                final end = start + 0.5;
                final animation = CurvedAnimation(
                  parent: _expandAnimation,
                  curve: Interval(start, end, curve: Curves.easeOutBack),
                  reverseCurve:
                      Interval(start, end, curve: Curves.easeInOutCubic),
                );

                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1).animate(animation),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3), // slide dari bawah
                        end: Offset.zero,
                      ).animate(animation),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: MiniFab(
                            icon: item.icon,
                            label: item.title,
                            onTap: () {
                              _toggleFab();

                              // Contoh navigasi FAB "Text"
                              if (item.title == 'Text') {
                                Future.delayed(
                                    const Duration(milliseconds: 200), () {
                                  if (!context.mounted) return;
                                  // Misal note baru dengan id 'new'
                                  context.push('/note/new');
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 4),

              // 🟢 Main FAB
              FloatingActionButton(
                onPressed: _toggleFab,
                backgroundColor:
                    _isExpanded ? Colors.redAccent : Colors.blueAccent,
                elevation: 6,
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.125 : 0, // animasi putar icon
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: const Icon(
                    PhosphorIconsDuotone.plus,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
