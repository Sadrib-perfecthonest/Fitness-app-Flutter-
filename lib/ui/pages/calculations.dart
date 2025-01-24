import 'dart:convert';
import 'package:http/http.dart' as http;

class NutrientCalculator {
  late double weight;
  late double height;
  late int age;
  late String gender;
  late String activityLevel;

  NutrientCalculator();

  // Fetch user data from the backend
  Future<void> fetchUserData(String token) async {
    try {
      // Call the backend API to get user data
      final response = await http.get(
        Uri.parse('http://0.0.0.0:3000/check-login'),
        headers: {
          'Authorization': token, // Pass the user's token for authentication
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body)['user'];

        // Assign user details to variables
        weight = userData['weight'];
        height = userData['height'];
        age = userData['age'];
        gender = userData['hobby']; // Assuming gender is stored in 'hobby'
        activityLevel = "light"; // Default activity level, can be updated later
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
      rethrow;
    }
  }

  // Calculate daily calories
  double get dailyCalories {
    double bmr = 10 * weight + 6.25 * height - 5 * age;
    if (gender.toLowerCase() == "male") {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    // Adjust for activity level
    double activityMultiplier;
    switch (activityLevel.toLowerCase()) {
      case "sedentary":
        activityMultiplier = 1.2;
        break;
      case "light":
        activityMultiplier = 1.375;
        break;
      case "moderate":
        activityMultiplier = 1.55;
        break;
      case "active":
        activityMultiplier = 1.725;
        break;
      case "very active":
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2; // Default to sedentary
    }

    return bmr * activityMultiplier;
  }

  // Macronutrient calculations
  double get proteinGrams => (dailyCalories * 0.20) / 4; // 20% to protein
  double get carbsGrams => (dailyCalories * 0.50) / 4; // 50% to carbs
  double get fatGrams => (dailyCalories * 0.30) / 9; // 30% to fat

  // Calculate all nutrients
  Map<String, double> calculate() {
    return {
      "dailyCalories": dailyCalories,
      "proteinGrams": proteinGrams,
      "carbsGrams": carbsGrams,
      "fatGrams": fatGrams,
    };
  }
}
