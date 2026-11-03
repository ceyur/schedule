import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class Profile extends StatefulWidget {
  const Profile(this.mySchedule, {super.key});
  final List<List<String>> mySchedule;

  @override
  State<Profile> createState() => _Profile();
} // Profile

class _Profile extends State<Profile> {
  final selectedType = "group";
  
  void getList() async {
    final groups = await Supabase.instance.client
      .from('groups')
      .select('group_name');
    final teachers = await Supabase.instance.client
      .from('teachers')
      .select('teacher');
  }

  @override
  void initState() {
    super.initState();
    getList();
  } // initState

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          // 2. Верхний переключатель (Material 3 SegmentedButton)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<FilterType>(
                segments: const <ButtonSegment<FilterType>>[
                  ButtonSegment<FilterType>(
                    value: FilterType.groups,
                    label: Text('Группы'),
                    icon: Icon(Icons.group),
                  ),
                  ButtonSegment<FilterType>(
                    value: FilterType.teachers,
                    label: Text('Преподаватели'),
                    icon: Icon(Icons.person),
                  ),
                ],
                selected: <FilterType>{_selectedType},
                onSelectionChanged: (Set<FilterType> newSelection) {
                  setState(() {
                    if (selectedType == "teacher") selectedType = "group";
                    else selectedType = "teacher";
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          // 3. Список, который обновляется при изменении _selectedType
          Expanded(
            child: FutureBuilder<List<String>>(
              // Ключ заставляет FutureBuilder перезапускаться при смене типа
              key: ValueKey(selectedType), 
              future: selectedType == "group" ? groups : teachers,
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
                  itemCount: listItems.count, // Ошибка в примере? Нет, itemCount: listItems.length
                  itemCount: listItems.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final item = listItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(item),
                        leading: Icon(
                          selectedType == "group"
                              ? Icons.school
                              : Icons.assignment_ind,
                        ),
                        onTap: () {
                          // Обработка клика по группе или преподу
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
