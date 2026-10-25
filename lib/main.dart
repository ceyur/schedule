import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:schedule/schedule.dart";
import "package:schedule/comments.dart";
import "package:schedule/profile.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting("ru_RU");

  await Supabase.initialize(
    url: "https://opgbfhxtmsyxhgwzxhbk.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wZ2JmaHh0bXN5eGhnd3p4aGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI5MzQyNDUsImV4cCI6MjEwODUxMDI0NX0.5F04aHDye9i9nzSfD3dZQX-39blWcFwBIbHEWjwhq8w",
    // publishableKey: "sb_publishable_F5iQTu_jSHTlkVTsfmTVaQ_OlYME8mu",
    // anonKey: const String.fromEnvironment("SUPABASE_ANON_KEY", defaultValue: "YOUR_FALLBACK_KEY"),
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
} // MyApp

class _MyApp extends State<MyApp> {
  static const List<Widget> pages = [Schedule(), Comments(), Profile()];
  static const items = [
    BottomNavigationBarItem(label: "Расписание", icon: Icon(Icons.calendar_month),),
    BottomNavigationBarItem(label: "Отзывы", icon: Icon(Icons.chat),),
    BottomNavigationBarItem(label: "Профиль", icon: Icon(Icons.account_circle),),
  ]; // items
  
  int selectedPage = 0;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: items[selectedPage].label,
      home: Scaffold(
        body: IndexedStack(
          index: selectedPage,
          children: pages,
        ), // IndexedStack
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ), // ThemeData
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: BottomNavigationBar(
                backgroundColor: Colors.tealAccent,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.teal, // Colors.black45,
                selectedFontSize: 15,
                unselectedFontSize: 15,
                items: items,
                currentIndex: selectedPage,
                onTap: (index) {
                  setState(() {
                    selectedPage = index;
                    // title = items[index].label;
                  });
                }, // onTap
              ), // BottomNavigationBar
            ), // ClipRRect
          ), // Padding
        ), // Theme
      ), // Scaffold
    ); // MaterialApp
  } // build
} // _MyApp
