import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:fitnessapp/ui/pages/profile_screen_button.dart';
import 'package:fitnessapp/ui/pages/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:fitnessapp/model/meal.dart';
import 'package:fitnessapp/ui/pages/meal_detail_screen.dart';
import 'package:fitnessapp/ui/pages/workout_screen.dart';
import 'package:vector_math/vector_math_64.dart' as math;
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final String username;
  final String profileImage;

  ProfileScreen({required this.username, required this.profileImage, Key? key})
      : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double kcalProgress = 0.0; // For _RadialProgress
  int kcalLeft = 0;
  double proteinProgress = 0.0, carbsProgress = 0.0, fatProgress = 0.0;
  int proteinLeft = 0, carbsLeft = 0, fatLeft = 0;
  bool isLoading = true;

  List<Meal> fetchedMeals = [];
  List<dynamic> fetchedWorkouts = [];
  @override
  void initState() {
    super.initState();
    fetchNutritionData().then((_) => fetchWorkoutsFromBackend());
  }

  Future<void> fetchNutritionData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.0.105:3000/nutrition/${widget.username}'), // Replace with server's actual IP
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          kcalLeft = data['kcal'];
          proteinLeft = data['protein'];
          carbsLeft = data['carbs'];
          fatLeft = data['fat'];

          // Example max values (can be adjusted)
          const int maxKcal = 2000;
          const int maxProtein = 150;
          const int maxCarbs = 250;
          const int maxFat = 70;

          kcalProgress = kcalLeft / maxKcal;
          proteinProgress = proteinLeft / maxProtein;
          carbsProgress = carbsLeft / maxCarbs;
          fatProgress = fatLeft / maxFat;
          isLoading = false;
        });
        // Fetch meals after nutrition data
        await fetchMealsFromBackend();
      } else {
        throw Exception('Failed to load nutrition data');
      }
    } catch (e) {
      print("Error fetching nutrition data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMealsFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.0.105:3000/meals/$kcalLeft'), // Replace with your backend IP
      );

      if (response.statusCode == 200) {
        final List<dynamic> mealData = json.decode(response.body);
        setState(() {
          fetchedMeals = mealData.map((data) {
            return Meal(
              mealTime: data['mealTime'],
              name: data['name'],
              kiloCaloriesBurnt: data['kiloCaloriesBurnt'].toString(),
              timeTaken: data['timeTaken'],
              imagePath: data['imagePath'],
              ingredients: List<String>.from(data['ingredients']),
              preparation: data['preparation'],
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to fetch meals');
      }
    } catch (e) {
      print("Error fetching meals: $e");
    }
  }

  Future<void> fetchWorkoutsFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.105:3000/workouts/$kcalLeft'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> workoutData = json.decode(response.body);
        setState(() {
          fetchedWorkouts = workoutData.map((data) {
            return {
              "name": data['name'],
              "instruction": data['instruction'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to fetch workouts');
      }
    } catch (e) {
      print("Error fetching workouts: $e");
    }
  }

  int _currentIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfileScreenButton(
                  username: '',
                )),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 57, 34, 133),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        child: BottomNavigationBar(
          iconSize: 15,
          selectedIconTheme: IconThemeData(
            color: const Color(0xFF200087),
          ),
          unselectedIconTheme: IconThemeData(
            color: Colors.black12,
          ),
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Icon(Icons.home, color: Colors.black),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                child: Icon(Icons.search, color: Colors.black),
                padding: const EdgeInsets.only(top: 8.0),
              ),
              label: "Search",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                child: Icon(Icons.menu, color: Colors.black),
                padding: const EdgeInsets.only(top: 8.0),
              ),
              label: "Menu",
            ),
          ],
          selectedLabelStyle: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          backgroundColor: Color.fromARGB(255, 98, 81, 155),
          unselectedItemColor: Colors.black,
          unselectedLabelStyle: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          selectedItemColor: Colors.black,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  height: height * 0.35,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                    child: Container(
                      color: Color.fromARGB(255, 97, 84, 153),
                      padding: const EdgeInsets.only(
                          top: 30, left: 28, right: 14, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              "${DateFormat("EEEE").format(today)}, ${DateFormat("d MMMM").format(today)}",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18.sp,
                              ),
                            ),
                            subtitle: Text(
                              "Hello, ${widget.username}", // Use the dynamic username here
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 26.sp,
                                color: Colors.black,
                              ),
                            ),
                            trailing: ClipOval(
                              child: widget.profileImage.isNotEmpty
                                  ? Image.memory(
                                      base64Decode(widget
                                          .profileImage), // Decode the Base64 string into an image
                                      fit: BoxFit.cover,
                                      width: 50,
                                      height: 50,
                                    )
                                  : Image.asset(
                                      "assets/user.jpg", // Default image if no profile picture
                                      fit: BoxFit.cover,
                                      width: 50,
                                      height: 50,
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              _RadialProgress(
                                width: width * 0.4,
                                height: width * 0.4,
                                progress: kcalProgress,
                                kcalLeft: kcalLeft,
                                key: null,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _IngredientProgress(
                                    ingredient: "Protein",
                                    progress: proteinProgress,
                                    progressColor: Colors.green,
                                    leftAmount: proteinLeft,
                                    width: width * 0.28,
                                    key: null,
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  _IngredientProgress(
                                    ingredient: "Carbs",
                                    progress: carbsProgress,
                                    progressColor: Colors.red,
                                    leftAmount: carbsLeft,
                                    width: width * 0.28.w,
                                    key: null,
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  _IngredientProgress(
                                    ingredient: "Fat",
                                    progress: fatProgress,
                                    progressColor: Colors.yellow,
                                    leftAmount: fatLeft,
                                    width: width * 0.28.w,
                                    key: null,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.38,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: height * 0.61,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                            left: 20,
                            right: 16,
                          ),
                          child: Text(
                            "MEALS THAT RECOMMENDED",
                            style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        // Use FutureBuilder to fetch and display the meals
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 15.w,
                                ),
                                for (int i = 0; i < fetchedMeals.length; i++)
                                  _MealCard(
                                    meal: fetchedMeals[i],
                                    key: null,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: OpenContainer(
                            closedElevation: 0,
                            transitionType: ContainerTransitionType.fade,
                            transitionDuration:
                                const Duration(milliseconds: 1000),
                            closedColor: Color.fromARGB(255, 57, 34, 133),
                            openBuilder: (context, _) {
                              return WorkoutScreen(
                                imagePath: '',
                              );
                            },
                            closedBuilder:
                                (context, VoidCallback openContainer) {
                              return GestureDetector(
                                onTap: openContainer,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 60, left: 32, right: 32),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(0xFF5B4D9D),
                                        const Color(0xFF5B4D9D),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 15.0, left: 16),
                                        child: Text(
                                          "YOUR NEXT WORKOUT",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 2.0, left: 16),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(width: 20),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        WorkoutScreen(
                                                            imagePath:
                                                                "assets/chest.png"),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(25)),
                                                  color: const Color.fromARGB(
                                                      255, 56, 29, 145),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Image.asset(
                                                  "assets/chest.png",
                                                  width: 50,
                                                  height: 60,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        WorkoutScreen(
                                                            imagePath:
                                                                "assets/back.png"),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(25)),
                                                  color: Color.fromARGB(
                                                      255, 56, 29, 145),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Image.asset(
                                                  "assets/back.png",
                                                  width: 50,
                                                  height: 60,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        WorkoutScreen(
                                                            imagePath:
                                                                "assets/biceps.png"),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(25)),
                                                  color: Color.fromARGB(
                                                      255, 56, 29, 145),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Image.asset(
                                                  "assets/biceps.png",
                                                  width: 50,
                                                  height: 60,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                          ],
                                        ),
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
                  ),
                ),
              ],
            ),
    );
  }
}

class _IngredientProgress extends StatelessWidget {
  final String ingredient;
  final int leftAmount;
  final double progress, width;
  final Color progressColor;

  const _IngredientProgress(
      {required Key? key,
      required this.ingredient,
      required this.leftAmount,
      required this.progress,
      required this.progressColor,
      required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          ingredient.toUpperCase(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 10.h,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.black12,
                  ),
                ),
                Container(
                  height: 10.h,
                  width: width * progress,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: progressColor,
                  ),
                )
              ],
            ),
            SizedBox(
              width: 10.w,
            ),
            Text("${leftAmount}g left"),
          ],
        ),
      ],
    );
  }
}

class _RadialProgress extends StatelessWidget {
  final double height, width, progress;
  final int kcalLeft;
  const _RadialProgress({
    required Key? key,
    required this.height,
    required this.width,
    required this.progress,
    required this.kcalLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadialPainter(
        progress: 0.7,
      ),
      child: Container(
        height: height.h,
        width: width.w,
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$kcalLeft",
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF200087),
                  ),
                ),
                TextSpan(text: "\n"),
                TextSpan(
                  text: "kcal left",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF200087),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double progress;

  _RadialPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 10.w
      ..color = Color(0xFF200087)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double relativeProgress = 360 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2),
      math.radians(-90),
      math.radians(-relativeProgress),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;

  const _MealCard({required Key? key, required this.meal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        right: 20,
        bottom: 10,
      ),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Color(0xFF5B4D9D),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              fit: FlexFit.tight,
              child: OpenContainer(
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                transitionDuration: const Duration(milliseconds: 1000),
                openBuilder: (context, _) {
                  return MealDetailScreen(
                    meal: meal,
                    key: null,
                  );
                },
                closedBuilder: (context, openContainer) {
                  return GestureDetector(
                    onTap: openContainer,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Image.network(
                        meal.imagePath,
                        width: 225,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      meal.mealTime,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "${meal.kiloCaloriesBurnt} kcal",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.access_time,
                          size: 15.sp,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Text(
                          "${meal.timeTaken} min",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
