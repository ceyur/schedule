import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:schedule/data.dart";
import "package:schedule/schedule.dart";
import "package:schedule/profile.dart";
import "package:schedule/comments.dart";

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await initializeDateFormatting("ru_RU");
	
	await Supabase.initialize(
		url: "https://opgbfhxtmsyxhgwzxhbk.supabase.co",
		anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wZ2JmaHh0bXN5eGhnd3p4aGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI5MzQyNDUsImV4cCI6MjEwODUxMDI0NX0.5F04aHDye9i9nzSfD3dZQX-39blWcFwBIbHEWjwhq8w",
		// publishableKey: "sb_publishable_F5iQTu_jSHTlkVTsfmTVaQ_OlYME8mu",
		// anonKey: const String.fromEnvironment("SUPABASE_ANON_KEY", defaultValue: "YOUR_FALLBACK_KEY"),
	);
	
	data = await SharedPreferences.getInstance();
	if (data.getKeys().length != 0) {
		mySchedule = data.getKeys().map((key) {
			return [key, Type.values.byName(data.getString(key)!)];
		}).toList();
	} // if
	
	runApp(MyApp());
} // main

class MyApp extends StatefulWidget {
	const MyApp({super.key});
	
	@override
	State<MyApp> createState() => _MyApp();
} // MyApp

class _MyApp extends State<MyApp> {
	static const items = [
		BottomNavigationBarItem(label: "Расписание", icon: Icon(Icons.calendar_month),),
		BottomNavigationBarItem(label: "Отзывы", icon: Icon(Icons.chat),),
		BottomNavigationBarItem(label: "Профиль", icon: Icon(Icons.account_circle),),
	]; // items
	late final List<Widget> pages = const [Schedule(), Comments(), Profile()];
	
	@override
	Widget build(BuildContext context) {
		return ValueListenableBuilder<ThemeMode>(
			valueListenable: themeNotifier,
			builder: (context, themeMode, _) {
				return ValueListenableBuilder<int>(
					valueListenable: tabIndexNotifier,
					builder: (context, selectedIndex, _) {
						return MaterialApp(
							debugShowCheckedModeBanner: false,
							themeMode: themeMode,
							theme: ThemeData.light(useMaterial3: true),
								darkTheme: ThemeData.dark(useMaterial3: true),
							title: items[tabIndexNotifier.value].label,
							home: Scaffold(
								body: IndexedStack(
									index: tabIndexNotifier.value,
									children: pages,
								), // IndexedStack
								bottomNavigationBar: Padding(
									padding: const EdgeInsets.all(10),
									child: ClipRRect(
										borderRadius: BorderRadius.circular(99),
										child: BottomNavigationBar(
											backgroundColor: const Color(0xFF27D8D2),
											selectedItemColor: Colors.black,
											unselectedItemColor: Colors.teal, // Colors.black45
											selectedFontSize: 15,
											unselectedFontSize: 15,
											items: items,
											currentIndex: tabIndexNotifier.value,
											onTap: (index) {
												setState(() {
													tabIndexNotifier.value = index;
												}); // setState
											}, // onTap
										), // BottomNavigationBar
									), // ClipRRect
								), // Padding
							), // Scaffold
						); // MaterialApp
					}
				);
			}, // builder
		); // ValueListenableBuilder
	} // build
} // _MyApp
