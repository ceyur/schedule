import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _Schedule();
} // Schedule

class _Schedule extends State<Schedule> {
  static const mySchedule = [
    "23-03 ИСиП",
    "Шаидова Насиба Абдрашитовна",
    "ОЗИВТ(ППК-2)-25-1-у"
  ];
  
  String selectedValue = mySchedule[0];
  int selectedIndex = 0;
  final now = DateTime.now(); // Сегодняшняя дата
  int selectedDay = DateTime.now().weekday - 1; // Выбранная дата (индекс)
  final selectedDayDate = DateTime.now();

  // Future<List<dynamic>> scheduleFuture = getSchedule();

  DateTime get monday => now.subtract(Duration(days: now.weekday - 1));

  // Дата, выбранная в панели сверху
  DateTime get selectedDate => monday.add(Duration(days: selectedDay));

  // Дата в формате "2026-10-18"
  String formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  // Получить сегодняшнюю дату в виде 16 октября
  String getDate() {
    const months = [
      "января", "февраля", "марта", "апреля", "мая", "июня",
      "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ];
    
    return "${now.day} ${months[now.month - 1]}";
  } // getDate





  static const int _initialPage = 500; // страница "сейчас"
  
  final DateTime _now = DateTime.now();
  late final DateTime _baseMonday; // понедельник текущей недели
  int _selectedDay = 0;
  late final PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _baseMonday = _now.subtract(Duration(days: _now.weekday - 1));
    _pageController = PageController(initialPage: _initialPage);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // понедельник недели для конкретной страницы свайпа
  DateTime _mondayOfWeek(int page) =>
      _baseMonday.add(Duration(days: (page - _initialPage) * 7));
  
  // удобно для getSchedule(): выбранный день с учётом недели
  // DateTime get selectedDate =>
  //     _mondayOfWeek(_pageController.page?.round() ?? _initialPage)
  //         .add(Duration(days: _selectedDay));
  
  List<BottomNavigationBarItem> daysWeek(int page) {
    final monday = _mondayOfWeek(page);
    final weekOffset = page - _initialPage;
    final nowDay = _now.weekday - 1;
    const shortWeekDays = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"];
  
    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      final isToday = weekOffset == 0 && index == nowDay;
  
      return BottomNavigationBarItem(
        label: "",
        icon: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: isToday ? Border.all(color: Colors.black) : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                day.day.toString(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: index == _selectedDay ? Colors.black : Colors.teal,
                ),
              ),
              Text(
                shortWeekDays[index],
                style: TextStyle(
                  fontSize: 15,
                  color: index == _selectedDay ? Colors.black : Colors.teal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }



  
  // Элементы навигационной панели сверху
  // List<BottomNavigationBarItem> daysWeek() {
  //   final nowDay = now.weekday - 1;
  //   final monday = now.subtract(Duration(days: nowDay));
  //   const shortWeekDays = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"];
    
  //   return List.generate(7, (index) {
  //     final day = monday.add(Duration(days: index));

  //     return BottomNavigationBarItem(
  //       label: "",
  //       icon: Container(
  //         padding: const EdgeInsets.all(5),
  //         decoration: BoxDecoration(
  //           border: index == nowDay ? Border.all(color: Colors.black) : null,
  //           borderRadius: BorderRadius.circular(10),
  //         ), // BoxDecoration
  //         child: Column(
  //           children: [
  //             Text(
  //               day.day.toString(),
  //               style: TextStyle(
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.bold,
  //                 color: index == selectedDay ? Colors.black : Colors.teal, // const Color.fromARGB(255, 26, 185, 169),
  //               ), // TextStyle
  //             ), // Text
  //             Text(
  //               shortWeekDays[index],
  //               style: TextStyle(
  //                 fontSize: 15,
  //                 color: index == selectedDay ? Colors.black : Colors.teal, // const Color.fromARGB(255, 26, 185, 169),
  //               ), // TextStyle
  //             ), // Text
  //           ], // children
  //         ), // Column
  //       ), // Container
  //     ); // BottomNavigationBarItem
  //   }); // List.generate
  // } // daysWeek

  // Получить расписание на день
  Future<List<dynamic>> getSchedule() {
    return Supabase.instance.client
    .rpc(
        "pairsdaygroup",
        params: {
          "select_date": formatDate(selectedDate),
          "select_group": "23-03 ИСиП",
        },
      );
  } // getShedule

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
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
                          // scheduleFuture = getSchedule();
                        });
                      }, // onSelected
                      child: Row(
                        children: [
                          Text(
                            selectedValue,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ), // Text
                          const Icon(Icons.keyboard_arrow_down),
                        ], // children
                      ), // Row
                      itemBuilder: (BuildContext context) => mySchedule.map((group) {
                        return PopupMenuItem(
                          value: group,
                          child: Text(group),
                        );
                      }).toList(),
                      // itemBuilder: (BuildContext context) => [
                      //   const PopupMenuItem(value: "23-03 ИСиП", child: Text("23-03 ИСиП")),
                      //   const PopupMenuItem(value: "24-03 ИСиП", child: Text("24-03 ИСиП")),
                      //   const PopupMenuItem(value: "25-03 ИСиП", child: Text("25-03 ИСиП")),
                      // ], // itemBuilder
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
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  height: 70,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 1000, // запас недель в обе стороны
                    onPageChanged: (page) {
                      setState(() {
                        _selectedDay = 0; // сбрасываем выбранный день при смене недели
                      });
                    },
                    itemBuilder: (context, page) {
                      return BottomNavigationBar(
                        showSelectedLabels: false,
                        showUnselectedLabels: false,
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: const Color.fromARGB(255, 179, 255, 255),
                        selectedItemColor: Colors.black,
                        unselectedItemColor: Colors.teal,
                        selectedFontSize: 5,
                        unselectedFontSize: 5,
                        items: daysWeek(page),
                        currentIndex: _selectedDay,
                        onTap: (index) {
                          setState(() {
                            _selectedDay = index;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          
          // Theme(
          //   data: ThemeData(
          //     splashColor: Colors.transparent,
          //     highlightColor: Colors.transparent,
          //     hoverColor: Colors.transparent,
          //   ), // ThemeData
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          //     child: ClipRRect(
          //       borderRadius: BorderRadius.circular(99),
          //       child: BottomNavigationBar(
          //         showSelectedLabels: false,
          //         showUnselectedLabels: false,
          //         type: BottomNavigationBarType.fixed,
          //         backgroundColor: const Color.fromARGB(255, 179, 255, 255),
          //         selectedItemColor: Colors.black,
          //         unselectedItemColor: Colors.teal,
          //         selectedFontSize: 5,
          //         unselectedFontSize: 5,
          //         items: daysWeek(),
          //         currentIndex: selectedDay,
          //         onTap: (index) {
          //           setState(() {
          //             selectedDay = index;
          //             // scheduleFuture = getSchedule();
          //           });
          //         }, // onTap
          //       ), // BottomNavigationBar
          //     ), // ClipRRect
          //   ), // Padding
          // ), // Theme
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: getSchedule(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading instruments: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final instruments = snapshot.data!;
                if (instruments.length == 0) {
                  return const Text(
                    "В этот день нет пар",
                    style: TextStyle(
                      fontSize: 20,
                    )
                  );
                }
                else {
                  return ListView.builder(
                    itemCount: instruments.length,
                    itemBuilder: ((context, index) {
                      final instrument = instruments[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ), // RoundedRectangleBorder
                          child: Padding(
                            padding: const EdgeInsets.all(15),
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
                } // else
              }, // builder
            ), // FutureBuilder
          ), // Expanded
        ], // children
      ), // Column
    ); // Scaffold
  } // build
} // _Schedule
