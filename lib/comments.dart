import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class Comments extends StatefulWidget {
  const Comments({super.key});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _reviews = [];
  Map<String, dynamic>? _selectedTeacher;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
    _loadLatestReviews();
  }

  Future<void> _loadTeachers() async {
    try {
      final response = await supabase
          .from('teachers')
          .select('id, teacher')
          .order('teacher', ascending: true);
      
      setState(() {
        _teachers = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Ошибка загрузки преподавателей: $e');
    }
  }

  Future<void> _loadLatestReviews() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('reviews')
          .select('id, teacher_id, rating, comment, created_at, teachers(teacher)')
          .order('created_at', ascending: false)
          .limit(50);
      
      setState(() {
        _reviews = List<Map<String, dynamic>>.from(response);
        _selectedTeacher = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки отзывов: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReviewsForTeacher(int teacherId) async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('reviews')
          .select('id, teacher_id, rating, comment, created_at, teachers(teacher)')
          .eq('teacher_id', teacherId)
          .order('created_at', ascending: false);
      
      setState(() {
        _reviews = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки отзывов: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showWriteReviewDialog() {
    final commentController = TextEditingController();
    int selectedRating = 5;
    int? selectedTeacherId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Оставить отзыв'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Преподаватель',
                        border: OutlineInputBorder(),
                      ),
                      items: _teachers.map((t) {
                        return DropdownMenuItem<int>(
                          value: t['id'] as int,
                          child: Text(
                            t['teacher'] as String,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedTeacherId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Оценка:', style: TextStyle(fontSize: 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              selectedRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Текст отзыва',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedTeacherId == null || commentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Пожалуйста, выберите преподавателя и напишите отзыв')),
                      );
                      return;
                    }

                    try {
                      await supabase.from('reviews').insert({
                        'teacher_id': selectedTeacherId,
                        'rating': selectedRating,
                        'comment': commentController.text.trim(),
                      });
                      
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Отзыв успешно добавлен!')),
                        );
                        
                        if (_selectedTeacher != null && _selectedTeacher!['id'] == selectedTeacherId) {
                          _loadReviewsForTeacher(selectedTeacherId!);
                        } else {
                          _loadLatestReviews();
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Отправить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отзывы'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _teachers
                    .map((t) => t['teacher'] as String)
                    .where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                final teacher = _teachers.firstWhere((t) => t['teacher'] == selection);
                setState(() {
                  _selectedTeacher = teacher;
                });
                _loadReviewsForTeacher(teacher['id'] as int);
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Поиск преподавателя',
                    hintText: 'Введите ФИО преподавателя',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _selectedTeacher != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              textEditingController.clear();
                              setState(() => _selectedTeacher = null);
                              _loadLatestReviews();
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          
          if (_selectedTeacher != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20, color: Colors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Отзывы о преподавателе: ${_selectedTeacher!['teacher']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                    ? const Center(
                        child: Text(
                          'Отзывов пока нет.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          final teacherName = (review['teachers'] as Map?)?['teacher'] ?? 'Преподаватель';
                          final rating = review['rating'] as int;
                          final comment = review['comment'] as String;
                          final createdAt = DateTime.parse(review['created_at'] as String);

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          teacherName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(5, (starIndex) {
                                          return Icon(
                                            starIndex < rating ? Icons.star : Icons.star_border,
                                            color: Colors.amber,
                                            size: 20,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    comment,
                                    style: const TextStyle(fontSize: 14, height: 1.4),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormat('dd.MM.yyyy HH:mm', 'ru_RU').format(createdAt),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showWriteReviewDialog,
        backgroundColor: const Color(0xFF27D8D2),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.edit),
        label: const Text('Написать отзыв'),
      ),
    );
  }
}
