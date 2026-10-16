import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

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

  List<Widget> pages = [Schedule(), Commets(), Profile()];
  int selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: "Расписание",
      home: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: pages,
        ), // IndexedStack
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
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
                unselectedItemColor: Colors.black45,
                selectedFontSize: 15,
                unselectedFontSize: 15,
                items: const [
                  BottomNavigationBarItem(
                    label: "Расписание",
                    icon: Icon(Icons.calendar_month),
                  ), // BottomNavigationBarItem
                  BottomNavigationBarItem(
                    label: "Отзывы",
                    icon: Icon(Icons.chat),
                  ), // BottomNavigationBarItem
                  BottomNavigationBarItem(
                    label: "Профиль",
                    icon: Icon(Icons.account_circle),
                  ), // BottomNavigationBarItem
                ], // items
                currentIndex: selectedIndex,
                onTap: (index) {
                  setState(() {
                    selectedIndex = index;
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

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _Schedule();
} // Timing

class _Schedule extends State<Schedule> {
  String selectedValue = "23-03 ИСиП";
  int selectedIndex = 0;
  final now = DateTime.now(); // Сегодняшняя дата
  int selectedDay = DateTime.now().weekday - 1; // Выбранная дата (индекс)
  final selectedDayDate = DateTime.now();
  
  final schedule = Supabase.instance.client
    .rpc(
        "pairsdaygroup",
        params: {
          "select_date": "2026-10-09",
          "select_group": "23-03 ИСиП",
        },
      );

  // Получить сегодняшнюю дату (16 октября)
  String getDate() {
    const months = [
      "января", "февраля", "марта", "апреля", "мая", "июня",
      "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ];
    
    return "${now.day} ${months[now.month - 1]}";
  } // getDate

  // Навигационная панель сверху
  List<BottomNavigationBarItem> daysWeek() {
    final nowDay = now.weekday - 1;
    final monday = now.subtract(Duration(days: nowDay));
    const shortWeekDays = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"];
    
    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));

      return BottomNavigationBarItem(
        label: "",
        icon: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: index == nowDay ? Border.all(color: Colors.black) : null,
            borderRadius: BorderRadius.circular(10),
          ), // BoxDecoration
          child: Column(
            children: [
              Text(
                day.day.toString(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: index == selectedDay ? Colors.black : const Color.fromARGB(255, 26, 185, 169),
                ), // TextStyle
              ), // Text
              Text(
                shortWeekDays[index],
                style: TextStyle(
                  fontSize: 15,
                  color: index == selectedDay ? Colors.black : const Color.fromARGB(255, 26, 185, 169),
                ), // TextStyle
              ), // Text
            ], // children
          ), // Column
        ), // Container
      ); // BottomNavigationBarItem
    }); // List.generate
  } // daysWeek

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PopupMenuButton(
                      position: PopupMenuPosition.under,
                      tooltip: "",
                      initialValue: selectedValue,
                      onSelected: (String newValue) {
                        setState(() {
                          selectedValue = newValue;
                        });
                      }, // onSelected
                      child: Row(
                        children: [
                          Text(
                            selectedValue,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
                          ), // Text
                          const Icon(Icons.keyboard_arrow_down),
                        ], // children
                      ), // Row
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(value: "23-03 ИСиП", child: Text("23-03 ИСиП")),
                        const PopupMenuItem(value: "24-03 ИСиП", child: Text("24-03 ИСиП")),
                        const PopupMenuItem(value: "25-03 ИСиП", child: Text("25-03 ИСиП")),
                      ], // itemBuilder
                    ), // PopupMenuButton
                    Transform.translate(
                      offset: const Offset(0, -5),
                      child: Text(
                        textAlign: TextAlign.left,
                        getDate()
                      ), // Text
                    ), // Transform.translate
                  ], // children
                ), // Column
                const Spacer(),
                const Icon(Icons.filter_alt_outlined),
                const Icon(Icons.calendar_month),
              ], // children
            ), // Row
          ), // Padding
          Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ), // ThemeData
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: BottomNavigationBar(
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: const Color.fromARGB(255, 179, 255, 255),
                  selectedItemColor: Colors.black,
                  unselectedItemColor: Colors.teal,
                  selectedFontSize: 5,
                  unselectedFontSize: 5,
                  items: daysWeek(),
                  currentIndex: selectedDay,
                  onTap: (index) {
                    setState(() {
                      selectedDay = index;
                    });
                  }, // onTap
                ), // BottomNavigationBarItem
              ), // ClipRRect
            ), // Padding
          ), // Theme
          Expanded(
            child: FutureBuilder(
              future: schedule,
              builder: (context, snapshot) {
                final instruments = snapshot.data!;
                return ListView.builder(
                  itemCount: instruments.length,
                  itemBuilder: ((context, index) {
                    final instrument = instruments[index];
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ), // RoundedRectangleBorder
                        child: Padding(
                          // padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              // Левая колонка: Время + Предмет + Преподаватель
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      instrument["time_start"] + "-" + instrument["time_end"],
                                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                                    ), // Text
                                    const SizedBox(height: 4),
                                    Text(
                                      instrument["subject"],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ), // Text
                                    const SizedBox(height: 4),
                                    Text(
                                      instrument["teacher"],
                                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                                    ), // Text
                                  ], // children
                                ), // Column
                              ), // Expanded
                              const SizedBox(width: 15),
                              
                              // Правая колонка: Кабинет
                              Column(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    instrument["room"],
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ), // Text
                                ], // children
                              ), // Column
                            ], // children
                          ), // Row
                        ), // Padding
                      ), // Card
                    ); // Padding
                  }), // itemBuilder
                ); // ListView.builder
              }, // builder
            ), // FutureBuilder
          ), // Expanded
        ], // children
      ), // Column
    ); // Scaffold
  } // build
} // _Timing

class Commets extends StatelessWidget {
  const Commets({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Отзывы")),
    ); // Scaffold
  } // build
} // _Commets

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Профиль")),
    ); // Scaffold
  } // build
} // _Profile
