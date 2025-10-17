import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrivexcode_home_widget/presentation/widgets/empty_state.dart';
import 'package:flutter_thrivexcode_home_widget/presentation/widgets/note_widget_updater.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_thrivexcode_home_widget/data/local/app_database.dart';
import 'package:flutter_thrivexcode_home_widget/data/providers/note_provider.dart';
import 'package:flutter_thrivexcode_home_widget/presentation/screens/home_screen.dart';
import 'package:flutter_thrivexcode_home_widget/presentation/screens/note_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  await NoteWidgetUpdater.init();

  runApp(MainApp(database: db));
}

class MainApp extends StatefulWidget {
  final AppDatabase database;
  const MainApp({super.key, required this.database});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final GoRouter _router;
  static const platform = MethodChannel('flutter_thrivexcode/widget');

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),

        // more-specific route must come before param route
        GoRoute(
          path: '/note/new',
          builder: (context, state) => const NoteDetailScreen(note: null),
        ),

        GoRoute(
          path: '/note/:noteId',
          builder: (context, state) {
            final noteId = state.pathParameters['noteId']!;
            if (noteId == 'new') {
              // safety fallback (shouldn't happen if /note/new is above)
              return const NoteDetailScreen(note: null);
            }

            final noteProvider = context.watch<NoteProvider>();
            if (noteProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final note = noteProvider.getNoteById(noteId);
            if (note == null) {
              return EmptyState();
            }
            return NoteDetailScreen(note: note);
          },
        ),
      ],
    );

    // Listener untuk MethodChannel dari Android widget
    platform.setMethodCallHandler((call) async {
      if (call.method == 'openNoteDetail') {
        final noteId = call.arguments as String;
        debugPrint("Received noteId from widget: $noteId");

        // Navigasi dengan HomeScreen sebagai root agar tombol back bisa kembali
        _router.go('/');
        Future.delayed(const Duration(milliseconds: 100), () {
          _router.push('/note/$noteId');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: widget.database),
        ChangeNotifierProvider(create: (_) => NoteProvider(widget.database)),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
