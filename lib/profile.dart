import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:shared_preferences/shared_preferences.dart";
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
	// late final data;
	
	void getData() async {
		final data = await SharedPreferences.getInstance();
	}
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
		getData();
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
										final item = listItems[index] as Map<String, dynamic>;

										final String displayName = selectedType == Type.group
											? item["group_name"]?.toString() ?? ""
											: item["teacher"]?.toString() ?? "";
									
										bool isFavorite = false;
										int foundIndex = -1;
										int counter = 0;
										
										for (var element in mySchedule) {
											if (element.length >= 2 && element[0] == displayName && element[1] == selectedType) {
												foundIndex = counter;
												isFavorite = true;
												break;
											}
											counter++;
										}
										
										return Card(
											margin: const EdgeInsets.symmetric(vertical: 6),
											child: ListTile(
												title: Text(displayName),
												leading: Icon(
													selectedType == Type.group ? Icons.school : Icons.assignment_ind,
												),
												trailing: Icon(
													isFavorite ? Icons.star : Icons.star_border,
													color: isFavorite ? Colors.orange : Colors.grey,
												),
												onTap: () {
													setState(() {
														if (isFavorite) {
															mySchedule.removeAt(foundIndex);
															data.remove(displayName);
														}
														else {
															mySchedule.add([displayName, selectedType]);
															data.add([displayName, selectedType]);
														}
													}); // setState
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
