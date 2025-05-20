import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_heatmap.dart';
import 'package:habit_tracker/db/habit_database.dart';
import 'package:habit_tracker/model/habit.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';

import '../habit_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).getHabits();

    super.initState();
  }

  final TextEditingController textEditingController = TextEditingController();

  void createNewHabit() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: "Create new Habit",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            actions: [
              // save button
              MaterialButton(
                onPressed: () {
                  // get new habit name
                  String newHabitName = textEditingController.text;
                  // save to db
                  context.read<HabitDatabase>().insertHabit(newHabitName);

                  // pop box
                  Navigator.pop(context);

                  // clear controller
                  textEditingController.clear();
                },
                child: const Text('Save'),
              ),

              // cancel button
              MaterialButton(
                onPressed: () {
                  // pop box
                  Navigator.pop(context);

                  // clear controller
                  textEditingController.clear();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void toggleHabit(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().toggleHabitCompletion(habit.id!, value);
    }
  }

  // edit habit box
  void editHabitBox(Habit habit) {
    textEditingController.text = habit.name;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: TextField(controller: textEditingController),
            actions: [
              // save button
              MaterialButton(
                onPressed: () {
                  // get new habit name
                  String newHabitName = textEditingController.text;
                  // save to db
                  context.read<HabitDatabase>().updateHabitName(
                    habit.id!,
                    newHabitName,
                  );

                  // pop box
                  Navigator.pop(context);

                  // clear controller
                  textEditingController.clear();
                },
                child: const Text('Save'),
              ),

              // cancel button
              MaterialButton(
                onPressed: () {
                  // pop box
                  Navigator.pop(context);

                  // clear controller
                  textEditingController.clear();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  // delete habit box
  void deleteHabitBox(Habit habit) {
    textEditingController.text = habit.name;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Are you sure?"),
            actions: [
              // save button
              MaterialButton(
                onPressed: () {
                  // save to db
                  context.read<HabitDatabase>().deleteHabit(habit.id!);

                  textEditingController.clear();

                  // pop box
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),

              // cancel button
              MaterialButton(
                onPressed: () {
                  // pop box
                  Navigator.pop(context);

                  // clear controller
                  textEditingController.clear();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNewHabit();
        },
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: ListView(children: [_buildHeatMap(), _buildHabitList()]),
    );
  }

  Widget _buildHeatMap() {
    final db = context.watch<HabitDatabase>();

    List<Habit> currHabits = db.currentHabits;

    return FutureBuilder<DateTime?>(
      future: db.getFirstStartTime(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MyHeatmap(
            startData: snapshot.data!,
            dataset: prepareMapDataSet(currHabits),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildHabitList() {
    // habit db
    final db = context.watch<HabitDatabase>();
    List<Habit> currentHabits = db.currentHabits;

    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // get individual habit
        final habit = currentHabits[index];
        // check if completed today
        bool completedToday = isHabitCompletedToday(habit.completedDays);

        // return habit tile UI
        return MyHabitTile(
          text: habit.name,
          isCompleted: completedToday,
          onChanged: (value) => toggleHabit(value, habit),
          onEdit: (context) => editHabitBox(habit),
          onDelete: (context) => deleteHabitBox(habit),
        );
      },
    );
  }
}
