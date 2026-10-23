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
  static const startWeekI = 500;
  final weekController = PageController(initialPage: startWeekI);
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
  int selectedWeekI = startWeekI;

  DateTime selectedDay = DateTime.now();
  int selectedDayI = DateTime.now().weekday - 1;
  DateTime monday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  DateTime get mondayOfWeek => monday.add(Duration(days: (selectedWeekI - 500) * 7));

  late Future<List<dynamic>> schedule;

  @override
  void initState() {
    super.initState();
    schedule = getSchedule();
  }

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
                        );
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
                  // borderRadius: BorderRadius.circular(99),
                ), // BoxDecoration
                // margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                height: 69,
                child: PageView.builder(
                  controller: weekController,
                  itemCount: 1000,
                  onPageChanged: (week) {
                    setState(() {
                      selectedWeekI = week;
                      selectedDay = mondayOfWeek.add(Duration(days: selectedDayI));
                      schedule = getSchedule();
                    });
                  },
                  itemBuilder: (context, week) {
                    final monday = mondayOfWeek;
                    final weekOffset = selectedWeekI - 500;
                    final nowDay = DateTime.now().weekday - 1;
                    //const shortWeekDays = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"];
    
                    return Row(
                      children: [
                        SizedBox(
                          width: 2,
                          child: Container(color: Colors.teal.withOpacity(0.3)),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(7, (index) {
                              final day = monday.add(Duration(days: index));
                              final isToday = weekOffset == 0 && index == nowDay;
                          
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDayI = index;
                                    selectedDay = mondayOfWeek.add(Duration(days: selectedDayI));
                                    schedule = getSchedule();
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
                                          color: index == selectedDayI ? Colors.black : Colors.teal,
                                        ), // TextStyle
                                      ), // Text
                                      Text(
                                        DateFormat("EEE", "ru").format(day).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: index == selectedDayI ? Colors.black : Colors.teal,
                                        ), // TextStyle
                                      ), // Text
                                    ], // children
                                  ), // Column
                                ), // Container
                              ); // GestureDetector
                            }), // List.generate
                          ), // Row
                        ), // Expanded
                      ], // children
                    ); // Row
                  }, // itemBuilder
                ), // PageView.builder
              ), // Container
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: schedule,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text("Ошибка загрузки: ${snapshot.error}"),
                      ),
                       Theme(
                        data: ThemeData(
                          splashFactory: NoSplash.splashFactory,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                        ), // ThemeData
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                          ),
                          onPressed: () {
                            setState(() {
                              schedule = getSchedule();
                            });
                          },
                          child: const Text("Попробовать снова"),
                        ),
                      ),
                    ],
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final instruments = snapshot.data!;
                if (instruments.isEmpty) {
                  return const Text(
                    "В этот день нет пар",
                    style: const TextStyle(fontSize: 20),
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
            ), // FutureBuilder
          ), // Expanded
        ], // children
      ), // Column
    ); // Scaffold
  } // build
} // _Schedule
