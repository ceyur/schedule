// class _MyPageState extends State<MyPage> {
//   DateTime selectedDate = DateTime.now();
//   DateTime startOfWeek = /* понедельник текущей недели */;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Ваше приложение')),
//       body: Column(
//         children: [
//           // ПАНЕЛЬ С ДАТАМИ
//           GestureDetector(
//             onHorizontalDragEnd: (details) {
//               setState(() {
//                 final v = details.primaryVelocity ?? 0;
//                 if (v < 0) {
//                   startOfWeek = startOfWeek.add(const Duration(days: 7));  // свайп влево
//                 } else if (v > 0) {
//                   startOfWeek = startOfWeek.subtract(const Duration(days: 7)); // вправо
//                 }
//                 // при желании: selectedDate = тот же день недели новой недели
//               });
//             },
//             child: Row(
//               children: [
//                 for (int i = 0; i < 7; i++)
//                   Builder(builder: (context) {
//                     final day = startOfWeek.add(Duration(days: i));
//                     return GestureDetector(
//                       onTap: () => setState(() => selectedDate = day),
//                       child: DayCell(day: day, isSelected: day == selectedDate),
//                     );
//                   }),
//               ],
//             ),
//           ),
//           // НАПОЛНЕНИЕ
//           Expanded(
//             child: YourContentWidget(selectedDate: selectedDate),
//           ),
//         ],
//       ),
//     );
//   }
// }
import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:schedule/schedule.dart";
import "package:schedule/comments.dart";
import "package:schedule/profile.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://nknqqqirkfcaxtosnyhf.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5rbnFxcWlya2ZjYXh0b3NueWhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE1NDc0ODAsImV4cCI6MjEwNzEyMzQ4MH0.kEYWJ-lffILyHh_ICnmpeuFgwdqWjqkeHHeDGjeg4AQ",
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
            // highlightColor: Colors.transparent,
            // hoverColor: Colors.transparent,
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
