import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:supabase_flutter/supabase_flutter.dart";

enum FilterType { group, teacher }

class Profile extends StatefulWidget {
  const Profile(this.mySchedule, {super.key});
  final List<List<String>> mySchedule;

  @override
  State<Profile> createState() => _Profile();
} // Profile

class _Profile extends State<Profile> {
  FilterType selectedType = FilterType.group;
  Future<List<String>>? groups;
  Future<List<String>>? teachers;
  
  void getGroups() async {
    final groups = await Supabase.instance.client
      .from('groups')
      .select('group_name');
  }
  void getTeachers() async {
    final teachers = await Supabase.instance.client
      .from('teachers')
      .select('teacher');
  }

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
              child: SegmentedButton<FilterType>(
                segments: const <ButtonSegment<FilterType>>[
                  ButtonSegment<FilterType>(
                    value: FilterType.group,
                    label: Text('Группы'),
                    icon: Icon(Icons.group),
                  ),
                  ButtonSegment<FilterType>(
                    value: FilterType.teacher,
                    label: Text('Преподаватели'),
                    icon: Icon(Icons.person),
                  ),
                ],
                selected: <FilterType>{selectedType},
                onSelectionChanged: (Set<FilterType> newSelection) {
                  setState(() {
                    if (selectedType == FilterType.teacher) selectedType = FilterType.group;
                    else selectedType = FilterType.teacher;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<String>>(
              key: ValueKey(selectedType), 
              future: selectedType == FilterType.group ? groups : teachers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Данные не найдены'));
                }

                final listItems = snapshot.data!;

                return ListView.builder(
                  itemCount: listItems.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final item = listItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(item),
                        leading: Icon(
                          selectedType == FilterType.group
                              ? Icons.school
                              : Icons.assignment_ind,
                        ),
                        onTap: () {
                          print('Выбрано: $item');
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
