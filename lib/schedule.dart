import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _Schedule();
} // Schedule

class _Schedule extends State<Schedule> {
  static const months = [
    "января", "февраля", "марта", "апреля", "мая", "июня",
    "июля", "августа", "сентября", "октября", "ноября", "декабря"
  ];
  static const mySchedule = [
    "23-03 ИСиП",
    "Шаидова Насиба Абдрашитовна",
    "ОЗИВТ(ППК-2)-25-1-у"
  ];
  String selectedSchedule = mySchedule[0];
// 100 * 7 + 100 * 7 = 1400
// 700 : 100 = 7
// 700 % 100 = 0
  static const startWeekI = 100;
  final weekController = PageController(initialPage: startWeekI);
  int selectedWeekI = startWeekI;

  DateTime selectedDay = DateTime.now();
  static int startDayI = startWeekI * 7 + DateTime.now().weekday - 1;
  final dayController = PageController(initialPage: startDayI);
  int selectedDayI = startWeekI * 7 + DateTime.now().weekday - 1; // 700 + 4
  // startWeekI * 7 % startWeekI
  DateTime monday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  DateTime get mondayOfWeek => monday.add(Duration(days: (selectedWeekI - startWeekI) * 7));

  late Future<List<dynamic>> schedule;

  Future<List<dynamic>> getSchedule() {
    return Supabase.instance.client
    .rpc(
        "pairsdaygroup",
        params: {
          "select_date": DateFormat("yyyy-MM-dd").format(selectedDay),
          "select_group": "23-03 ИСиП",
        },
      );
  } // getSchedule

  @override
  void initState() {
    super.initState();
    schedule = getSchedule();
  } // initState

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
                      initialValue: selectedSchedule,
                      onSelected: (String value) {
                        setState(() {
                          selectedSchedule = value;
                          // schedule = getSchedule();
                        });
                      }, // onSelected
                      child: Row(
                        children: [
                          Text(
                            selectedSchedule,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ), // Text
                          const Icon(Icons.keyboard_arrow_down),
                        ], // children
                      ), // Row
                      itemBuilder: (BuildContext context) => mySchedule.map((group) {
                        return PopupMenuItem(
                          value: group,
                          child: Text(group),
                        ); // PopupMenuItem
                      }).toList(),
                    ), // PopupMenuButton
                    Transform.translate(
                      offset: const Offset(0, -5),
                      child: Text(
                        "${DateTime.now().day} ${months[DateTime.now().month - 1]}",
                        textAlign: TextAlign.left,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 179, 255, 255),
                ), // BoxDecoration
                height: 69,
                child: PageView.builder(
                  controller: weekController,
                  itemCount: startWeekI * 2,
                  onPageChanged: (week) {
                    setState(() {
                      selectedDayI = selectedDayI + (week - selectedWeekI) * 7;
                      selectedDay = mondayOfWeek.add(Duration(days: selectedDayI - selectedWeekI * 7));
                      selectedWeekI = week;
                      schedule = getSchedule();
                      dayController.jumpToPage(selectedDayI);
                    });
                  }, // onPageChanged
                  itemBuilder: (context, week) {
                    final monday = monday.add(Duration(days: (week - startWeekI) * 7));;
                    final weekOffset = selectedWeekI - startWeekI;
                    final nowDay = DateTime.now().weekday - 1;
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        final day = monday.add(Duration(days: index));
                        final isToday = weekOffset == 0 && index == nowDay;
                    
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDayI = selectedWeekI * 7 + index;
                              selectedDay = mondayOfWeek.add(Duration(days: selectedDayI - selectedWeekI * 7));
                              schedule = getSchedule();
                              dayController.jumpToPage(selectedDayI);
                            });
                          }, // onTap
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: isToday ? Border.all(color: Colors.black) : null,
                              borderRadius: BorderRadius.circular(10),
                            ), // Container
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: index == selectedDayI - selectedWeekI * 7 ? Colors.black : Colors.teal,
                                  ), // TextStyle
                                ), // Text
                                Text(
                                  DateFormat("EEE", "ru").format(day).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: index == selectedDayI - selectedWeekI * 7 ? Colors.black : Colors.teal,
                                  ), // TextStyle
                                ), // Text
                              ], // children
                            ), // Column
                          ), // Container
                        ); // GestureDetector
                      }), // List.generate
                    ); // Row
                  }, // itemBuilder
                ), // PageView.builder
              ), // Container
            ), // ClipRRect
          ), // Padding
          Expanded(
            child: PageView.builder(
              controller: dayController,
              itemCount: startDayI * 2,
              onPageChanged: (day) {
                setState(() {
                  selectedDayI = day;
                  selectedDay = mondayOfWeek.add(Duration(days: selectedDayI - selectedWeekI * 7));
                  if (selectedWeekI != (selectedDayI / 7).toInt()) {
                    selectedWeekI = (selectedDayI / 7).toInt();
                    weekController.jumpToPage(selectedWeekI);
                  }
                  schedule = getSchedule();
                });
              }, // onPageChanged
              itemBuilder: (context, day) {
                return FutureBuilder<List<dynamic>>(
                  future: schedule,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text("Ошибка загрузки: ${snapshot.error}"),
                          ), // Padding
                          Theme(
                            data: ThemeData(
                              splashFactory: NoSplash.splashFactory,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                            ), // ThemeData
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                              ), // ElevatedButton.styleFrom
                              onPressed: () {
                                setState(() {
                                  schedule = getSchedule();
                                }); // setState
                              }, // onPressed
                              child: const Text("Попробовать снова"),
                            ), // ElevatedButton
                          ), // Theme
                        ], // children
                      ); // Column
                    } // if
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    } // if
                    final instruments = snapshot.data!;
                    if (instruments.isEmpty) {
                      return const Text(
                        "В этот день нет пар",
                        style: const TextStyle(fontSize: 20),
                      ); // Text
                    } // if
                    else {
                      return ListView.builder(
                        itemCount: instruments.length,
                        itemBuilder: ((context, index) {
                          final instrument = instruments[index];
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ), // RoundedRectangleBorder
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${instrument["time_start"]}–${instrument["time_end"]}",
                                            style: const TextStyle(color: Colors.grey, fontSize: 15),
                                          ), // Text
                                          const SizedBox(height: 4),
                                          Text(
                                            instrument["subject"],
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                          ), // Text
                                          const SizedBox(height: 4),
                                          Text(
                                            instrument["teacher"],
                                            style: const TextStyle(fontSize: 15, color: Colors.grey),
                                          ), // Text
                                        ], // children
                                      ), // Column
                                    ), // Expanded
                                    const SizedBox(width: 15),
                                    Column(
                                      children: [
                                        Text(
                                          instrument["room"],
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                ); // FutureBuilder
              }, // itemBuilder
            ), // PageView.builder
          ), // Expanded
        ], // children
      ), // Column
    ); // Scaffold
  } // build
} // _Schedule
