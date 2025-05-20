import 'dart:convert';

class Habit {
  final int? id;
  late String name;
  List<DateTime> completedDays = [
    // DateTime(year, month, day)
    // DateTime(2025, 01, 03)
  ];

  Habit({this.id, required this.name, required this.completedDays});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'completed_days': jsonEncode(
        completedDays.map((d) => d.toIso8601String()).toList(),
      ),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      completedDays:
          (jsonDecode(map['completed_days']) as List)
              .map((d) => DateTime.parse(d))
              .toList(),
    );
  }
}
