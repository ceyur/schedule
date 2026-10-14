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
      title: "Расписание",
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
  // final List<Subject> schedule1 = [
  //   Subject(date: "11.10.2026", timeStart: "08:30", timeEnd: "10:00", name: "Разработка мобильных приложений", teacher: "Иванов И.И.", room: "404 каб."),
  //   Subject(date: "09.10.2026", timeStart: "10:10", timeEnd: "11:40", name: "Операционные системы", teacher: "Петров П.П.", room: "102 каб."),
  //   Subject(date: "09.10.2026", timeStart: "11:50", timeEnd: "13:20", name: "Физическая культура", teacher: "Сидоров С.С.", room: "Спортзал"),
  // ];

  String selectedValue = "23-03 ИСиП";
  int selectedIndex = 0;
  final now = DateTime.now();
  int selectedDay = DateTime.now().weekday - 1;
  
  final schedule = Supabase.instance.client
    .from("schedule")
    .select("date,
            pairs(time_start time_end),
            groups(group),
            subjects(subject),
            teachers(teacher),
            rooms(room)")
    .eq("group", selectedValue)
    .eq("group", selectedDay);
  
  String getDate() {
    const months = [
      "января", "февраля", "марта", "апреля", "мая", "июня",
      "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ];
    
    return "${now.day} ${months[now.month - 1]}";
  } // getDate

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
            border: index == nowDay ? Border.all(color: Colors.teal) : null,
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
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,),
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
                if (snapshot.hasError) {
                  return Center(child: Text("Ошибка загрузки: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final instruments = snapshot.data!;
                return ListView.builder(
                  itemCount: instruments.length,
                  itemBuilder: ((context, index) {
                    final instrument = instruments[index];
                    return Text(
                      "ль"
                      // "${instrument["date"]} ${instrument["group_id"]} ${instrument["pair_id"]} ${instrument["subject_id"]} ${instrument["teacher_id"]} ${instrument["room_id"]}"
                    );
                    // return Card(
                    //   margin: const EdgeInsets.only(bottom: 10),
                    //   elevation: 2,
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(15),
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(12),
                    //     child: Row(
                    //       children: [
                    //         // Левая колонка: Время (Начало -> полоска -> Конец)
                    //         Column(
                    //           children: [
                    //             Text(
                    //               instrument["timeStart"],
                    //               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    //             ),
                    //             const SizedBox(height: 4),
                    //             Container(width: 2, height: 15, color: Colors.teal),
                    //             const SizedBox(height: 4),
                    //             Text(
                    //               instrument["timeEnd"],
                    //               style: const TextStyle(color: Colors.grey, fontSize: 14),
                    //             ),
                    //           ],
                    //         ),
                    //         const SizedBox(width: 15),
                            
                    //         // Правая колонка: Информация о предмете
                    //         Expanded(
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               // Название предмета (переносится максимум на 2 строки)
                    //               Text(
                    //                 instrument["name"],
                    //                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    //                 maxLines: 2,
                    //                 overflow: TextOverflow.ellipsis,
                    //               ),
                    //               const SizedBox(height: 6),
                                  
                    //               // Строка с преподавателем и кабинетом
                    //               Row(
                    //                 children: [
                    //                   const Icon(Icons.person, size: 16, color: Colors.grey),
                    //                   const SizedBox(width: 4),
                    //                   Expanded(
                    //                     child: Text(
                    //                       instrument["teacher"],
                    //                       style: const TextStyle(color: Colors.grey, fontSize: 13),
                    //                     ),
                    //                   ),
                    //                   // Голубой бэдж для номера кабинета
                    //                   Container(
                    //                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    //                     decoration: BoxDecoration(
                    //                       color: Colors.teal,
                    //                       borderRadius: BorderRadius.circular(8),
                    //                     ),
                    //                     child: Text(
                    //                       instrument["room"],
                    //                       style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ); // Card
                  }),
                );
              },
            ),
            // ListView.builder(
            //   // Отступы по бокам списка
            //   padding: const EdgeInsets.symmetric(horizontal: 10), 
            //   // Количество элементов в списке
            //   itemCount: schedule.length, 
            //   // Функция сборки каждой отдельной карточки
            //   itemBuilder: (context, index) {
            //     final subject = schedule[index];
                
            //     return Card(
            //       margin: const EdgeInsets.only(bottom: 10),
            //       elevation: 2,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(15),
            //       ),
            //       child: Padding(
            //         padding: const EdgeInsets.all(12),
            //         child: Row(
            //           children: [
            //             // Левая колонка: Время (Начало -> полоска -> Конец)
            //             Column(
            //               children: [
            //                 Text(
            //                   subject.timeStart,
            //                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            //                 ),
            //                 const SizedBox(height: 4),
            //                 Container(width: 2, height: 15, color: Colors.teal),
            //                 const SizedBox(height: 4),
            //                 Text(
            //                   subject.timeEnd,
            //                   style: const TextStyle(color: Colors.grey, fontSize: 14),
            //                 ),
            //               ],
            //             ),
            //             const SizedBox(width: 15),
                        
            //             // Правая колонка: Информация о предмете
            //             Expanded(
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   // Название предмета (переносится максимум на 2 строки)
            //                   Text(
            //                     subject.name,
            //                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            //                     maxLines: 2,
            //                     overflow: TextOverflow.ellipsis,
            //                   ),
            //                   const SizedBox(height: 6),
                              
            //                   // Строка с преподавателем и кабинетом
            //                   Row(
            //                     children: [
            //                       const Icon(Icons.person, size: 16, color: Colors.grey),
            //                       const SizedBox(width: 4),
            //                       Expanded(
            //                         child: Text(
            //                           subject.teacher,
            //                           style: const TextStyle(color: Colors.grey, fontSize: 13),
            //                         ),
            //                       ),
            //                       // Голубой бэдж для номера кабинета
            //                       Container(
            //                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            //                         decoration: BoxDecoration(
            //                           color: Colors.teal,
            //                           borderRadius: BorderRadius.circular(8),
            //                         ),
            //                         child: Text(
            //                           subject.room,
            //                           style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12),
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     );
            //   },
            // ),
            
          ),
        ], // children
      ), // Column
    ); // Scaffold
  } // build
} // _Timing

class Subject {
  final String date;
  final String timeStart;
  final String timeEnd;
  final String name;
  final String teacher;
  final String room;

  Subject({
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.name,
    required this.teacher,
    required this.room,
  });
}

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
