import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:url_strategy/url_strategy.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:schedule/data.dart";
import "package:schedule/schedule.dart";
import "package:schedule/profile.dart";
import "package:schedule/comments.dart";

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();

	setPathUrlStrategy(); 
	
	await initializeDateFormatting("ru_RU");
	
	await Supabase.initialize(
		url: "https://opgbfhxtmsyxhgwzxhbk.supabase.co",
		publishableKey: const String.fromEnvironment("SUPABASE_PUBLISHABLE_KEY"),
		// anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wZ2JmaHh0bXN5eGhnd3p4aGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI5MzQyNDUsImV4cCI6MjEwODUxMDI0NX0.5F04aHDye9i9nzSfD3dZQX-39blWcFwBIbHEWjwhq8w",
		// publishableKey: "sb_publishable_nLo4QeJ_DZciaV3UmOiZxA_gkdTLKsk",
		// anonKey: const String.fromEnvironment("SUPABASE_ANON_KEY", defaultValue: "YOUR_FALLBACK_KEY"),
	); // Supabase.initialize
	
	data = await SharedPreferences.getInstance();
	if (data.getKeys().length != 0) {
		mySchedule = data.getKeys().map((key) {
			return [key, Type.values.byName(data.getString(key)!)];
		}).toList();
	} // if
	
	runApp(MyApp());
} // main

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return ValueListenableBuilder<ThemeMode>(
			valueListenable: themeNotifier,
			builder: (context, themeMode, _) {
				return MaterialApp.router(
					debugShowCheckedModeBanner: false,
					themeMode: themeMode,
					theme: ThemeData.light(useMaterial3: true),
					darkTheme: ThemeData.dark(useMaterial3: true),
					routerConfig: router,
				); // MaterialApp
			}, // builder
		); // ValueListenableBuilder
	} // build
} // MyApp

final router = GoRouter(
	initialLocation: "/main",
	routes: [
		StatefulShellRoute.indexedStack(
			builder: (context, state, navigationShell) {
				return Scaffold(
					body: navigationShell, 
					bottomNavigationBar: Padding(
						padding: const EdgeInsets.all(10),
						child: ClipRRect(
							borderRadius: BorderRadius.circular(99),
							child: BottomNavigationBar(
								backgroundColor: const Color(0xFF27D8D2),
								selectedItemColor: Colors.black,
								unselectedItemColor: Colors.teal,
								selectedFontSize: 15,
								unselectedFontSize: 15,
								items: const [
									BottomNavigationBarItem(label: "Расписание", icon: Icon(Icons.calendar_month)),
									BottomNavigationBarItem(label: "Отзывы", icon: Icon(Icons.chat)),
									BottomNavigationBarItem(label: "Профиль", icon: Icon(Icons.account_circle)),
								], // items
								currentIndex: navigationShell.currentIndex,
								onTap: (index) {
									navigationShell.goBranch(index);
								}, // onTap
							), // BottomNavigationBar
						), // ClipRRect
					), // Padding
				); // Scaffold
			}, // builder
			branches: [
				StatefulShellBranch(
					routes: [
						GoRoute(
							path: "/main",
							builder: (context, state) => const Schedule(),
						), // GoRoute
					], // routes
				), // StatefulShellBranch
				StatefulShellBranch(
					routes: [
						GoRoute(
							path: "/comments",
							builder: (context, state) => const Comments(),
						), // GoRoute
					], // routes
				), // StatefulShellBranch
				StatefulShellBranch(
					routes: [
						GoRoute(
							path: "/profile",
							builder: (context, state) => const Profile(),
						), // GoRoute
					], // routes
				), // StatefulShellBranch
			], // branches
		), // StatefulShellRoute
	], // routes
); // GoRouter
