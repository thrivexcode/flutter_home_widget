import 'package:flutter/material.dart';
import 'package:flutter_thrivexcode_home_widget/presentation/widgets/action_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum SortOption {
  custom,
  dateCreated,
  dateModified,
}

class TopActionBar extends StatefulWidget {
  final Color? iconColor;
  final bool isPreview;
  const TopActionBar({
    super.key,
    this.iconColor,
    this.isPreview = false,
  });

  @override
  State<TopActionBar> createState() => _TopActionBarState();
}

class _TopActionBarState extends State<TopActionBar> {
  bool isGrid = true;
  SortOption selectedSort = SortOption.dateModified;

  void _toggleLayout() {
    setState(() => isGrid = !isGrid);
    // TODO: callback ke parent (jika mau sync ke UI utama)
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: NoteSearchDelegate(),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 16.0,
              ),
              child: Text(
                "Sort by",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),
            _buildSortTile(context, SortOption.custom, "Custom",
                PhosphorIconsDuotone.slidersHorizontal),
            _buildSortTile(context, SortOption.dateCreated, "Date created",
                PhosphorIconsDuotone.calendarPlus),
            _buildSortTile(context, SortOption.dateModified, "Date modified",
                PhosphorIconsDuotone.clockClockwise),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildSortTile(
      BuildContext context, SortOption option, String title, IconData icon) {
    final isSelected = selectedSort == option;
    final iconColor = Theme.of(context).iconTheme.color;
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      trailing: isSelected
          ? Icon(PhosphorIconsDuotone.checkCircle, color: Colors.blue)
          : null,
      onTap: () {
        setState(() => selectedSort = option);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? Theme.of(context).iconTheme.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left menu icon
        ActionIcon(
          config: ActionIconConfig(
            icon: PhosphorIconsDuotone.list,
            iconColor: iconColor,
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),

        // Search Bar
        Expanded(
          child: GestureDetector(
            onTap: _showSearch,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.magnifyingGlass,
                    size: 20,
                    color: iconColor?.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Search your notes",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: iconColor?.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _toggleLayout,
                    child: Icon(
                      isGrid
                          ? PhosphorIconsDuotone.squaresFour
                          : PhosphorIconsDuotone.rows,
                      size: 20,
                      color: iconColor?.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 🔹 Sort icon
                  GestureDetector(
                    onTap: _showSortSheet,
                    child: Icon(
                      PhosphorIconsDuotone.arrowsDownUp,
                      size: 20,
                      color: iconColor?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Profile icon
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// 🔍 Custom SearchDelegate
class NoteSearchDelegate extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);

    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.black45),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.black87),
      ),
      scaffoldBackgroundColor: Colors.white,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(PhosphorIconsRegular.xCircle, color: Colors.black87),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(PhosphorIconsRegular.arrowLeft, color: Colors.black87),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          'Hasil pencarian untuk "$query"',
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          'Cari catatan yang berisi "$query"',
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
