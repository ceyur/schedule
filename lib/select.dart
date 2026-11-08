import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:schedule/profile.dart";
import "package:schedule/data.dart";

class Select extends StatefulWidget {
	const Select({super.key});
	
	@override
	State<Select> createState() => _Select();
} // Select

class _Select extends State<Select> {
	Type selectedType = Type.group;
	late Future<List<dynamic>> groups;
	late Future<List<dynamic>> teachers;
	late Future<List<dynamic>> rooms;

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
	Future<List<dynamic>> getRooms() async {
		return await Supabase.instance.client
			.from("rooms")
			.select("room");
	} // getRooms
	
	@override
	void initState() {
		super.initState();
		groups = getGroups();
		teachers = getTeachers();
		rooms = getRooms();
	} // initState
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				children: [
					Align(
						alignment: Alignment.topRight,
						child: Padding(
							padding: const EdgeInsets.only(top: 10, right: 10),
							child: IconButton(
								icon: const Icon(Icons.close),
								style: IconButton.styleFrom(
									shape: const CircleBorder(),
								),
								onPressed: () {
									tabIndexNotifier.value = 2;
									Navigator.pop(context);
								},
							),
						),
					),
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
									ButtonSegment<Type>(
										value: Type.room,
										label: Text("Аудитории"),
										icon: Icon(Icons.person),
									), // ButtonSegment
								], // segments
								selected: <Type>{selectedType},
								onSelectionChanged: (Set<Type> newSelection) {
									setState(() {
										selectedType = newSelection.first;
									}); // setState
								}, // onSelectionChanged
							), // SegmentedButton
						), // SizedBox
					), // Padding
					const SizedBox(height: 10),
					Expanded(
						child: FutureBuilder<List<dynamic>>(
							key: ValueKey(selectedType), 
							future: selectedType == Type.group ? groups : selectedType == Type.teacher ? teachers : rooms,
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
											: selectedType == Type.teacher
												? item["teacher"]?.toString() ?? ""
												: item["room"]?.toString() ?? "";
										
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
												), // Icon
												trailing: Icon(
													isFavorite ? Icons.star : Icons.star_border,
													color: isFavorite ? Colors.orange : Colors.grey,
												), // Icon
												onTap: () {
													setState(() {
														if (isFavorite) {
															mySchedule.removeAt(foundIndex);
															data.remove(displayName);
														}
														else {
															mySchedule.add([displayName, selectedType]);
															data.setString(displayName, selectedType.name);
														}
													}); // setState
												}, // onTap
											), // ListTile
										); // Card
									}, // itemBuilder
								); // ListView.builder
							}, // builder
						), // FutureBuilder
					), // Expanded
				], // children
			), // Column
		); // Scaffold
	} // build
} // _Select
