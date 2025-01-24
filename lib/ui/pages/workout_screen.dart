import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitnessapp/model/upper_body_workout.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WorkoutScreen extends StatefulWidget {
  final String imagePath; // Accept the selected imagePath

  WorkoutScreen({required this.imagePath});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<UpperBodyWorkout> filteredWorkouts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  Future<void> fetchWorkouts() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.0.105:3000/workouts/1000')); // Replace with your backend endpoint
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        setState(() {
          // Filter exercises based on the selected imagePath
          filteredWorkouts = data
              .where((workout) {
                if (widget.imagePath == "assets/chest.png") {
                  return workout['name'].toLowerCase().contains('bench') ||
                      workout['name'].toLowerCase().contains('dumbbell');
                } else if (widget.imagePath == "assets/back.png") {
                  return workout['name'].toLowerCase().contains('pull') ||
                      workout['name'].toLowerCase().contains('deadlift') ||
                      workout['name'].toLowerCase().contains('lat');
                } else if (widget.imagePath == "assets/biceps.png") {
                  return workout['name'].toLowerCase().contains('curl') ||
                      workout['name'].toLowerCase().contains('biceps');
                }
                return false;
              })
              .map((workout) => UpperBodyWorkout(
                    imagePath: widget.imagePath, // Use the selected imagePath
                    name: workout['name'],
                    instruction: workout['instruction'],
                  ))
              .toList();

          isLoading = false;
        });
      } else {
        print('Failed to load workouts: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching workouts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 49, 20, 141),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // Header with date
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ListTile(
                        title: Text(
                          "${DateFormat("EEEE").format(today)}, ${DateFormat("d MMMM").format(today)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          "Workout",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Display filtered workouts
                    ...filteredWorkouts.map((workout) {
                      return ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF5B4D9D),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            workout.imagePath,
                            width: 50,
                            height: 50,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          workout.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          workout.instruction,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }
}
