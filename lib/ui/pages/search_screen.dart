import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Meals data for 100-500
  final List<Map<String, dynamic>> meals = [
    // 100 kcal
    {
      "mealTime": "BREAKFAST",
      "kiloCaloriesBurnt": 100,
      "ingredients": [
        "1/2 cup diced tomatoes",
        "1/2 cup diced cucumbers",
        "1 tsp olive oil",
        "Pinch of salt and pepper",
      ],
      "preparation":
          "Wash the tomatoes and cucumbers thoroughly under cold water. Dice them and add to a mixing bowl. Drizzle olive oil, season with salt and pepper. Toss and serve.",
    },
    {
      "mealTime": "LUNCH",
      "name": "Steamed Broccoli",
      "kiloCaloriesBurnt": 100,
      "ingredients": ["1 cup steamed broccoli", "Pinch of salt"],
      "preparation":
          "Rinse the broccoli and cut into florets. Steam for 5-7 minutes and season with salt. Serve.",
    },
    {
      "mealTime": "SNACK",
      "name": "Apple Slices",
      "kiloCaloriesBurnt": 100,
      "name": "Tomato Cucumber Salad",
      "ingredients": ["1 medium apple"],
      "preparation":
          "Wash the apple and slice into wedges. Serve as a healthy snack.",
    },
    // 200 kcal
    {
      "mealTime": "BREAKFAST",
      "name": "Egg Salad Wrap",
      "kiloCaloriesBurnt": 200,
      "ingredients": [
        "1 boiled egg",
        "1 whole-grain tortilla",
        "1 tsp mayonnaise",
        "Lettuce leaves",
      ],
      "preparation":
          "Boil the egg and chop it. Mix with mayo, place in tortilla with lettuce, roll and serve.",
    },
    {
      "mealTime": "LUNCH",
      "name": "Grilled Asparagus",
      "kiloCaloriesBurnt": 200,
      "ingredients": [
        "1 cup asparagus",
        "1 tsp olive oil",
        "Pinch of salt and pepper",
      ],
      "preparation":
          "Wash asparagus, trim, grill for 4-6 minutes with olive oil and seasoning. Serve.",
    },
    {
      "mealTime": "SNACK",
      "name": "Banana with Peanut Butter",
      "kiloCaloriesBurnt": 200,
      "ingredients": ["1 banana", "1 tsp peanut butter"],
      "preparation": "Slice banana, spread peanut butter on slices, and serve.",
    },
    // 300 kcal
    {
      "mealTime": "BREAKFAST",
      "name": "Vegetable Soup",
      "kiloCaloriesBurnt": 300,
      "ingredients": [
        "1 cup vegetable broth",
        "1/2 cup diced carrots",
        "1/2 cup diced celery",
        "1/4 cup diced onions",
      ],
      "preparation":
          "Saute onions, add carrots, celery, and broth. Simmer for 15 minutes, season and serve.",
    },
    {
      "mealTime": "LUNCH",
      "name": "Baked Sweet Potato",
      "kiloCaloriesBurnt": 300,
      "ingredients": ["1 medium sweet potato", "1 tsp butter"],
      "preparation":
          "Bake sweet potato at 375°F for 25-30 minutes. Add butter and season before serving.",
    },
    {
      "mealTime": "SNACK",
      "name": "Cheese Crackers",
      "kiloCaloriesBurnt": 300,
      "ingredients": ["5 whole-grain crackers", "1 slice of cheddar cheese"],
      "preparation": "Place cheese slices on crackers and serve.",
    },
    // 400 kcal
    {
      "mealTime": "BREAKFAST",
      "name": "Chicken Caesar Salad",
      "kiloCaloriesBurnt": 400,
      "ingredients": [
        "1 grilled chicken breast",
        "2 cups romaine lettuce",
        "2 tbsp Caesar dressing",
        "1/4 cup croutons",
        "1 tbsp grated Parmesan cheese",
      ],
      "preparation":
          "Grill chicken, toss lettuce with dressing, add chicken, croutons, and Parmesan.",
    },
    {
      "mealTime": "LUNCH",
      "name": "Stuffed Bell Peppers",
      "kiloCaloriesBurnt": 400,
      "ingredients": [
        "2 bell peppers",
        "1/2 cup cooked quinoa",
        "1/4 cup black beans",
        "1/4 cup diced tomatoes",
        "1 tsp cumin",
        "1 tbsp olive oil",
      ],
      "preparation":
          "Stuff peppers with quinoa, beans, tomatoes, and cumin. Bake for 20 minutes.",
    },
    {
      "mealTime": "SNACK",
      "name": "Greek Yogurt ",
      "kiloCaloriesBurnt": 400,
      "ingredients": [
        "1 cup Greek yogurt",
        "1 tbsp honey",
        "1/4 cup mixed nuts",
      ],
      "preparation": "Add honey and nuts to yogurt, stir, and serve.",
    },
    // 500 kcal
    {
      "mealTime": "BREAKFAST",
      "name": "Avocado Toast with Egg",
      "kiloCaloriesBurnt": 500,
      "ingredients": [
        "1 whole-grain bread",
        "1/2 avocado",
        "1 boiled egg",
        "Salt and pepper",
      ],
      "preparation":
          "Toast bread, spread avocado, place boiled egg on top, season with salt and pepper. Serve.",
    },
    {
      "mealTime": "LUNCH",
      "name": "Grilled Chicken Quinoa Salad",
      "kiloCaloriesBurnt": 500,
      "ingredients": [
        "1 chicken breast",
        "1 cup quinoa",
        "1/2 cup mixed vegetables",
        "1 tbsp olive oil",
      ],
      "preparation":
          "Grill chicken, cook quinoa, stir-fry vegetables with olive oil. Serve together.",
    },
    {
      "mealTime": "SNACK",
      "name": "Protein Smoothie",
      "kiloCaloriesBurnt": 500,
      "ingredients": [
        "1 cup cottage cheese",
        "1/4 cup pineapple",
        "1 tbsp chia seeds",
      ],
      "preparation": "Mix cottage cheese with pineapple and chia seeds. Serve.",
    },
    // 600 kcal
    {
      "mealTime": "BREAKFAST",
      "name": "Peanut Butter Banana Toast",
      "kiloCaloriesBurnt": 600,
      "ingredients": [
        "2 slices whole grain bread",
        "2 tbsp peanut butter",
        "1 banana",
        "1 tsp honey (optional)",
      ],
      "preparation": "Toast the bread slices until crispy and golden. "
          "Spread peanut butter evenly on each slice of toast. "
          "Slice the banana into thin rounds and arrange the slices on top of the peanut butter. "
          "Drizzle honey on top for added sweetness if desired. "
          "Serve immediately as a quick and delicious breakfast.",
    },
    {
      "mealTime": "LUNCH",
      "name": "Grilled Salmon Vegetables",
      "kiloCaloriesBurnt": 600,
      "ingredients": [
        "1 salmon fillet",
        "1 cup mixed vegetables (carrots, zucchini, bell peppers)",
        "1 tbsp olive oil",
        "1 tsp lemon juice",
        "Salt and pepper to taste",
      ],
      "preparation": "Preheat the oven to 375°F (190°C). "
          "Toss the mixed vegetables in olive oil, salt, and pepper, and spread them out evenly on a baking tray. "
          "Place the salmon fillet on the same tray, drizzling with lemon juice and seasoning with salt and pepper. "
          "Roast everything in the oven for 20-25 minutes, or until the salmon is cooked through and the vegetables are tender. "
          "Serve the salmon and roasted vegetables hot for a fulfilling lunch.",
    },
    {
      "mealTime": "SNACK",
      "name": "Hummus and Carrot Sticks",
      "kiloCaloriesBurnt": 600,
      "ingredients": [
        "1/4 cup hummus",
        "1 large carrot",
      ],
      "preparation": "Peel and slice the carrot into thin sticks. "
          "Spoon the hummus into a small bowl for dipping. "
          "Serve the carrot sticks with the hummus for a crunchy, healthy snack.",
    },
    // 700 kcal
    {
      "mealTime": "BREAKFAST",
      "name": "Oatmeal with Almonds Berries",
      "kiloCaloriesBurnt": 700,
      "ingredients": [
        "1/2 cup rolled oats",
        "1 cup almond milk",
        "1/4 cup mixed berries",
        "2 tbsp chopped almonds",
        "1 tbsp maple syrup",
      ],
      "preparation": "In a pot, combine the rolled oats and almond milk. "
          "Bring to a boil, then reduce heat and simmer for about 5 minutes, stirring occasionally. "
          "Once the oats are cooked and creamy, pour into a bowl. "
          "Top with mixed berries, chopped almonds, and a drizzle of maple syrup. "
          "Serve immediately as a hearty and nutritious breakfast.",
    },
    {
      "mealTime": "LUNCH",
      "name": "Turkey and Avocado Wrap",
      "kiloCaloriesBurnt": 700,
      "ingredients": [
        "1 whole-grain tortilla",
        "4 oz sliced turkey breast",
        "1/2 avocado",
        "1/4 cup spinach leaves",
        "1 tbsp mustard or mayonnaise",
      ],
      "preparation": "Place the whole-grain tortilla on a flat surface. "
          "Layer the tortilla with sliced turkey breast, avocado slices, spinach leaves, and mustard or mayonnaise. "
          "Roll up the tortilla tightly, folding in the sides as you go to form a wrap. "
          "Serve immediately or wrap in foil for a lunch on the go.",
    },
    {
      "mealTime": "SNACK",
      "name": "Chia Seed Pudding",
      "kiloCaloriesBurnt": 700,
      "ingredients": [
        "3 tbsp chia seeds",
        "1 cup almond milk",
        "1 tsp vanilla extract",
        "1 tbsp honey",
      ],
      "preparation":
          "In a small bowl, combine the chia seeds, almond milk, vanilla extract, and honey. "
              "Stir well and cover the bowl with plastic wrap. "
              "Refrigerate for at least 2 hours or overnight to allow the chia seeds to expand and form a pudding-like texture. "
              "Serve chilled with a topping of fresh fruit or nuts if desired.",
    },
    // 800 kcal
    {
      "mealTime": "BREAKFAST",
      "name": "Scrambled Eggs with Avocado",
      "kiloCaloriesBurnt": 800,
      "ingredients": [
        "3 large eggs",
        "1/2 avocado",
        "1 tbsp butter",
        "Salt and pepper to taste",
      ],
      "preparation": "In a bowl, whisk the eggs and season with salt and pepper. "
          "Melt butter in a non-stick skillet over medium heat. "
          "Pour the eggs into the skillet and stir gently, allowing the eggs to scramble. "
          "Slice the avocado and serve alongside the scrambled eggs. "
          "Serve immediately for a filling and nutritious breakfast.",
    },
    {
      "mealTime": "LUNCH",
      "name": "Beef Stirfry with Rice",
      "kiloCaloriesBurnt": 800,
      "ingredients": [
        "4 oz beef (sirloin or flank steak)",
        "1/2 cup cooked rice",
        "1 cup mixed vegetables (bell peppers, onions, broccoli)",
        "2 tbsp soy sauce",
        "1 tbsp olive oil",
      ],
      "preparation": "Slice the beef into thin strips. "
          "Heat olive oil in a pan over medium-high heat. Add the beef and cook for 4-5 minutes until browned. "
          "Add the mixed vegetables to the pan and stir-fry for an additional 5 minutes until tender. "
          "Pour in the soy sauce and stir to coat everything evenly. "
          "Serve the stir-fry over the cooked rice for a complete meal.",
    },
    {
      "mealTime": "SNACK",
      "name": "Greek Yogurt Parfait",
      "kiloCaloriesBurnt": 800,
      "ingredients": [
        "1 cup Greek yogurt",
        "1/4 cup granola",
        "1/4 cup mixed berries",
        "1 tbsp honey",
      ],
      "preparation":
          "Layer the Greek yogurt, granola, and mixed berries in a bowl or glass. "
              "Drizzle honey over the top for added sweetness. "
              "Serve immediately as a satisfying snack or dessert.",
    },
    // 900 kcal
    {
      "mealTime": "BREAKFAST",
      "name": "Pancakes with Maple Syrup",
      "kiloCaloriesBurnt": 900,
      "ingredients": [
        "1 cup all-purpose flour",
        "1/2 cup milk",
        "1 egg",
        "1 tbsp sugar",
        "1 tbsp baking powder",
        "2 tbsp butter",
        "Maple syrup for topping",
      ],
      "preparation": "In a mixing bowl, combine the flour, sugar, and baking powder. "
          "Whisk in the milk, egg, and melted butter until smooth. "
          "Heat a griddle or pan over medium heat and lightly grease it with butter. "
          "Pour 1/4 cup of the batter onto the griddle for each pancake and cook for 2-3 minutes on each side until golden. "
          "Stack the pancakes and drizzle with maple syrup. "
          "Serve immediately for a delicious breakfast.",
    },
    {
      "mealTime": "LUNCH",
      "name": "Chicken Caesar Salad",
      "kiloCaloriesBurnt": 900,
      "ingredients": [
        "1 grilled chicken breast",
        "2 cups Romaine lettuce",
        "1/4 cup grated Parmesan cheese",
        "1/4 cup Caesar dressing",
        "Croutons",
      ],
      "preparation": "Grill the chicken breast and slice it into thin strips. "
          "In a large bowl, combine the Romaine lettuce, grated Parmesan cheese, and croutons. "
          "Toss the salad with Caesar dressing to coat everything evenly. "
          "Top with the grilled chicken slices. "
          "Serve immediately for a classic and satisfying lunch.",
    },
    {
      "mealTime": "SNACK",
      "name": "Chocolate Protein Bars",
      "kiloCaloriesBurnt": 900,
      "ingredients": [
        "1 cup oats",
        "1/4 cup protein powder",
        "1/4 cup peanut butter",
        "2 tbsp honey",
        "2 tbsp cocoa powder",
      ],
      "preparation":
          "In a bowl, combine oats, protein powder, cocoa powder, and honey. "
              "Stir in peanut butter and mix until everything is well combined. "
              "Press the mixture into a baking dish lined with parchment paper. "
              "Refrigerate for 1-2 hours to set. "
              "Cut into bars and serve as a high-protein snack.",
    },
  ];
// Search result list
  List<Map<String, dynamic>> filteredMeals = [];

  @override
  void initState() {
    super.initState();
  }

  void searchMeals(String query) {
    final suggestions = meals.where((meal) {
      final mealName = meal['name']?.toLowerCase() ?? ''; // null check
      final searchQuery = query.toLowerCase();
      return mealName.contains(searchQuery);
    }).toList();

    setState(() {
      filteredMeals = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 101, 91, 136),
      appBar: AppBar(
        title: Text(
          'Search Meals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 101, 91, 136),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              onChanged: searchMeals,
              decoration: InputDecoration(
                labelText: 'Search Meals',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredMeals.length,
                itemBuilder: (context, index) {
                  final meal = filteredMeals[index];
                  final mealName = meal['name'] ?? 'Unnamed Meal'; // null check
                  final mealCalories =
                      meal['kiloCaloriesBurnt']?.toString() ?? '0';

                  return ListTile(
                    title: Text(mealName),
                    subtitle: Text('Calories: $mealCalories kcal'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Color.fromARGB(255, 101, 91, 136),
                            title: Text(mealName),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Calories: $mealCalories kcal'),
                                SizedBox(height: 10),
                                Text('Ingredients:'),
                                for (var ingredient
                                    in meal['ingredients'] ?? [])
                                  Text('- $ingredient'),
                                SizedBox(height: 10),
                                Text('Preparation:'),
                                Text(meal['preparation'] ??
                                    'No preparation available'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Close',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 57, 34, 133))),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
