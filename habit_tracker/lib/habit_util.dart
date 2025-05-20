// given a habit list of completion days, is the habit completed today

import 'model/habit.dart';

bool isHabitCompletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();
  return completedDays.any(
    (date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day,
  );
}


// prepare heatmap
Map<DateTime, int> prepareMapDataSet(List<Habit> habits)  {
  Map<DateTime, int> dataset = {};

  for(var habit in habits) {
    for(var date in habit.completedDays) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if(dataset.containsKey(normalizedDate)) {
        dataset[normalizedDate] = dataset[normalizedDate]! + 1;
      } else {
        dataset[normalizedDate] = 1;
      }
    }
  }
  return dataset;
}
