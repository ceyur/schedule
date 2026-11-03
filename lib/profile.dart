import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:schedule/data.dart";

class Profile extends StatefulWidget {
	const Profile({super.key});

	@override
	State<Profile> createState() => _Profile();
} // Profile

class _Profile extends State<Profile> {
	Type selectedType = Type.group;
	late Future<List<dynamic>> groups;
	late Future<List<dynamic>> teachers;
	
	Future<List<dynamic>> getGroups() async {
		return await Supabase.instance.client
			.from("groups")
			.select("group_name");
	} // getGroups
	Future<List<dynamic>> getTeachers() async {
		return await Supabase.instance.client
			.from("teachers")
			.select("teacher");
	} // getTeachers

	@override
	void initState() {
		super.initState();
		groups = getGroups();
		teachers = getTeachers();
	} // initState

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				children: [
					const SizedBox(height: 10),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 10),
						child: SizedBox(
							width: double.infinity,
							child: SegmentedButton<Type>(
								segments: const <ButtonSegment<Type>>[
									ButtonSegment<Type>(
										value: Type.group,
										label: Text("Группы"),
										icon: Icon(Icons.group),
									), // ButtonSegment
									ButtonSegment<Type>(
										value: Type.teacher,
										label: Text("Преподаватели"),
										icon: Icon(Icons.person),
									), // ButtonSegment
								], // segments
								selected: <Type>{selectedType},
								onSelectionChanged: (Set<Type> newSelection) {
									setState(() {
										if (selectedType == Type.teacher) selectedType = Type.group;
										else selectedType = Type.teacher;
									}); // setState
								}, // onSelectionChanged
							), // SegmentedButton
						), // SizedBox
					), // Padding
					const SizedBox(height: 10),
					Expanded(
						child: FutureBuilder<List<dynamic>>(
							key: ValueKey(selectedType), 
							future: selectedType == Type.group ? groups : teachers,
							builder: (context, snapshot) {
								if (snapshot.connectionState == ConnectionState.waiting) {
									return const Center(child: CircularProgressIndicator());
								}
								else if (snapshot.hasError) {
									return Center(child: Text("Ошибка: ${snapshot.error}"));
								}
								else if (!snapshot.hasData || snapshot.data!.isEmpty) {
									return const Center(child: Text("Данные не найдены"));
								}

								final listItems = snapshot.data!;

								return ListView.builder(
									itemCount: listItems.length,
									padding: const EdgeInsets.symmetric(horizontal: 16),
									itemBuilder: (context, index) {
										// final item = listItems[index] as Map<String, dynamic>; // Явно приводим к Map
										
										// // Достаем строку по ключу в зависимости от выбранного фильтра
										// final String displayName = selectedType == Type.group
										// 		? item["group_name"]?.toString() ?? ""
										// 		: item["teacher"]?.toString() ?? "";
	
										// return Card(
										// 	margin: const EdgeInsets.symmetric(vertical: 6),
										// 	child: ListTile(
										// 		title: Text(displayName),
										// 		leading: Icon(
										// 			selectedType == Type.group
										// 					? Icons.school
										// 					: Icons.assignment_ind,
										// 		), // leading
										// 		onTap: () {
										// 			print("Выбрано: $displayName");
										// 		}, // onTap
										// 	), // ListTile
										// ); // Card



										final item = listItems[index] as Map<String, dynamic>;

										  // Достаем отображаемое имя и ID (ID нужен только если позже захочешь перейти на проверку по ID)
										  final String displayName = selectedType == Type.group
											  ? item["group_name"]?.toString() ?? ""
											  : item["teacher"]?.toString() ?? "";
										
										  // --- ГЛАВНОЕ: проверка, есть ли это в mySchedule ---
										  bool isFavorite = false;
										  
										  // Ищем совпадение по названию и типу
										  for (var entry in mySchedule) {
											if (entry.length >= 2 && entry[0] == displayName && entry[1] == selectedType) {
											  isFavorite = true;
											  break;
											}
										  }
										  // -----------------------------------------------------
										
										  return Card(
											margin: const EdgeInsets.symmetric(vertical: 6),
											child: ListTile(
											  title: Text(displayName),
											  leading: Icon(
												selectedType == Type.group ? Icons.school : Icons.assignment_ind,
											  ),
											  // Звезда справа: цвет и иконка зависят от isFavorite
											  trailing: Icon(
												isFavorite ? Icons.star : Icons.star_border,
												color: isFavorite ? Colors.orange : Colors.grey,
											  ),
											  onTap: () {
												print("Выбрано: $displayName");
												// Тут можно добавить логику добавления/удаления из mySchedule
											  },
											),
										  );
									}, // itemBuilder
								); // ListView.builder
							}, // builder
						), // FutureBuilder
					), // Expanded
				], // children
			), // Column
		); // Scaffold
	} // build
} // _Profile
