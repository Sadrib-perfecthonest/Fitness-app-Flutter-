const express = require("express");
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const cors = require("cors");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

// Initialize app
const app = express();
const port = 3000;

// Middleware
app.use(cors()); 
app.use(bodyParser.json({ limit: "10mb" })); 


mongoose
  .connect("mongodb://localhost:27017/echobeat", {
    
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("Connected to MongoDB"))
  .catch((err) => console.log("MongoDB connection error: ", err));


const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  age: Number,
  hobby: String,
  weight: Number,
  height: Number,
  dob: String,
  password: String, 
  profileImage: String, 
});

// Create User model
const User = mongoose.model("User", userSchema);



app.post("/register", async (req, res) => {
  const { username, age, hobby, weight, height, dob, password, profileImage } =
    req.body;

  try {
    // Hash the password before saving
    const hashedPassword = await bcrypt.hash(password, 10); // 10 is the salt rounds

    // Create new user document
    const newUser = new User({
      username,
      age,
      hobby,
      weight,
      height,
      dob,
      password: hashedPassword, // Save the hashed password
      profileImage, // Store the Base64 image string directly
    });

    // Save user to MongoDB
    await newUser.save();

    // Send success response
    res.status(201).json({ message: "User registered successfully" });
  } catch (err) {
    console.error("Error registering user:", err);
    res.status(500).json({ message: "Error registering user", error: err });
  }
});

// Route to handle user login
app.post("/login", async (req, res) => {
  const { username, password } = req.body;

  try {
    // Find user by username
    const user = await User.findOne({ username });

    if (!user) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // Compare the entered password with the hashed password in the database
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // Generate a JWT token
    const token = jwt.sign({ id: user._id }, "your_secret_key", { expiresIn: "1h" }); // Replace "your_secret_key" with a secure secret key

    // Send user data (excluding password) as response
    const { password: _, ...userData } = user._doc; // Exclude password field
    res.status(200).json({
      message: "Login successful",
      token,
      user: {
        ...userData,
        profileImage: user.profileImage || "", // Include Base64 image string
      },
    });
  } catch (err) {
    console.error("Error logging in:", err);
    res.status(500).json({ message: "Error logging in", error: err });
  }
});

// Route to check login status based on username
app.get("/check-login", async (req, res) => {
  try {
    const token = req.headers.authorization; // Expecting a token in the Authorization header
    if (!token) {
      return res.status(401).json({ message: "Not logged in" });
    }

    // Verify the token (using JWT or any preferred mechanism)
    const decoded = jwt.verify(token, "your_secret_key"); // Replace with your JWT secret

    // Retrieve user info based on the decoded data
    const user = await User.findById(decoded.id); // Assuming `User` is your MongoDB model

    if (user) {
      res.status(200).json({ user });
    } else {
      res.status(401).json({ message: "Not logged in" });
    }
  } catch (error) {
    res.status(401).json({ message: "Not logged in" });
  }
});

// Helper function to calculate kcal, protein, carbs, and fat
const calculateNutrition = (user) => {
  const { age, weight, height, hobby } = user;

  // Example BMR (Basal Metabolic Rate) calculation (Mifflin-St Jeor Equation)
  const bmr = 10 * weight + 6.25 * height - 5 * age + 5; // For men, adjust for women
  const activityMultiplier = hobby === "active" ? 1.55 : hobby === "moderate" ? 1.375 : 1.2;
  const dailyCalories = Math.round(bmr * activityMultiplier);

  // Example macro distribution (percentage of daily calories)
  const proteinCalories = Math.round(dailyCalories * 0.3);
  const carbsCalories = Math.round(dailyCalories * 0.5);
  const fatCalories = Math.round(dailyCalories * 0.2);

  return {
    kcal: dailyCalories,
    protein: Math.round(proteinCalories / 4), // Protein = 4 kcal/g
    carbs: Math.round(carbsCalories / 4),    // Carbs = 4 kcal/g
    fat: Math.round(fatCalories / 9),       // Fat = 9 kcal/g
  };
};

// Route to get dynamic nutrition values
app.get("/nutrition/:username", async (req, res) => {
  const { username } = req.params;

  try {
    const user = await User.findOne({ username });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const nutrition = calculateNutrition(user);

    res.status(200).json(nutrition);
  } catch (err) {
    console.error("Error fetching nutrition data:", err);
    res.status(500).json({ message: "Error fetching nutrition data", error: err });
  }
});// Route to fetch nutrition data dynamically
  
const meals = [
  // 100 kcal
  {
    mealTime: "BREAKFAST",
    name: "Tomato Cucumber Salad",
    kiloCaloriesBurnt: 100,
    timeTaken: "5",
    imagePath: "https://i0.wp.com/kristineskitchenblog.com/wp-content/uploads/2022/07/cucumber-tomato-salad-15-2.jpg?resize=1200,1800&ssl=1",
    ingredients: [
      "1/2 cup diced tomatoes",
      "1/2 cup diced cucumbers",
      "1 tsp olive oil",
      "Pinch of salt and pepper",
    ],
    preparation: `Wash the tomatoes and cucumbers thoroughly under cold water.
Dice the tomatoes and cucumbers into small, bite-sized pieces and add them to a mixing bowl.
Drizzle olive oil over the vegetables, ensuring they are evenly coated.
Season with a pinch of salt and pepper to taste.
Toss the salad gently to combine all the ingredients.
Let the salad rest for 1-2 minutes for the flavors to meld.
Serve immediately for a fresh and light meal.`,
  },
  {
    mealTime: "LUNCH",
    name: "Steamed Broccoli",
    kiloCaloriesBurnt: 100,
    timeTaken: "10",
    imagePath: "https://t4.ftcdn.net/jpg/01/20/16/29/360_F_120162940_wSq40Vbz512YbgSi60alfsDx2gfeB18x.jpg",
    ingredients: ["1 cup steamed broccoli", "Pinch of salt"],
    preparation: `Rinse the broccoli thoroughly under cold water.
Cut the broccoli into florets, making sure to remove any tough stems.
Boil a pot of water and place a steamer basket over it, ensuring the water does not touch the broccoli.
Steam the broccoli for 5-7 minutes until tender but still vibrant green.
Sprinkle with a pinch of salt and toss to coat.
Serve as a side dish or a light dinner option.`,
  },
  {
    mealTime: "SNACK",
    name: "Apple Slices",
    kiloCaloriesBurnt: 100,
    timeTaken: "2",
    imagePath: "https://img.freepik.com/free-photo/apple-slices-plate-marble_114579-87356.jpg?semt=ais_hybrid",
    ingredients: ["1 medium apple"],
    preparation: `Wash the apple under cold water to remove any wax or dirt.
Slice the apple into thin wedges or rounds, depending on your preference.
Serve the apple slices as a healthy, low-calorie snack.
For extra flavor, dip the slices in peanut butter or sprinkle cinnamon on top.`,
  },
  // 200 kcal
  {
    mealTime: "BREAKFAST",
    name: "Egg Salad Wrap",
    kiloCaloriesBurnt: 200,
    timeTaken: "10",
    imagePath: "https://www.jocooks.com/wp-content/uploads/2013/01/avocado-egg-salad-wraps-1-31.jpg",
    ingredients: [
      "1 boiled egg",
      "1 whole-grain tortilla",
      "1 tsp mayonnaise",
      "Lettuce leaves",
    ],
    preparation: `Begin by boiling the egg in a pot of water for 10 minutes until hard-boiled.
Once boiled, peel the egg and chop it into small pieces.
In a small bowl, mix the chopped egg with mayonnaise. Add more mayonnaise if needed to reach your desired consistency.
Lay the tortilla flat on a surface and spread the egg mixture evenly across it.
Add fresh lettuce leaves on top of the egg mixture for crunch.
Roll the tortilla tightly, folding in the sides as you go, to form a wrap.
Slice the wrap into halves or quarters for easy consumption.
Serve immediately or wrap in foil for a lunch to go.`,
  },
  {
    mealTime: "LUNCH",
    name: "Grilled Asparagus",
    kiloCaloriesBurnt: 200,
    timeTaken: "10",
    imagePath: "https://www.seriouseats.com/thmb/mhzbmKQYEKKnX5CqgSuUXx_cx04=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/__opt__aboutcom__coeus__resources__content_migration__serious_eats__seriouseats.com__images__2015__06__20150609-grilled-asparagus-tarragon-aioli-harissa-2-de3727e1a0d946e4b449e5eb33c1903a.jpg",
    ingredients: [
      "1 cup asparagus",
      "1 tsp olive oil",
      "Pinch of salt and pepper",
    ],
    preparation: `Wash the asparagus under cold water to remove any dirt or sand.
Trim the tough ends of the asparagus stalks, about 2-3 inches from the base.
Preheat a grill pan over medium heat for 2-3 minutes.
Drizzle the asparagus with olive oil and season with salt and pepper.
Place the asparagus on the grill pan and cook for 4-6 minutes, turning occasionally to ensure even cooking.
Grill until the asparagus is tender and has slight grill marks.
Serve hot, garnished with a little extra seasoning if desired.`,
  },
  {
    mealTime: "SNACK",
    name: "Banana with Peanut Butter",
    kiloCaloriesBurnt: 200,
    timeTaken: "3",
    imagePath: "https://www.eatingbirdfood.com/wp-content/uploads/2019/08/chocolate-peanut-butter-banana-bites.jpg",
    ingredients: ["1 banana", "1 tsp peanut butter"],
    preparation: `Peel the banana and slice it into rounds.
Spread a small amount of peanut butter on each slice of banana.
For extra flavor, sprinkle with cinnamon or drizzle honey on top.
Serve immediately as a satisfying and nutritious snack.`,
  },
  // 300 kcal
  {
    mealTime: "BREAKFAST",
    name: "Vegetable Soup",
    kiloCaloriesBurnt: 300,
    timeTaken: "20",
    imagePath: "https://media.istockphoto.com/id/1092632852/photo/vegetable-soup.jpg?s=612x612&w=0&k=20&c=TLMWC8lshitbk8pONGpblEsmcsBy1wZVQ9jJC92Cvh4=",
    ingredients: [
      "1 cup vegetable broth",
      "1/2 cup diced carrots",
      "1/2 cup diced celery",
      "1/4 cup diced onions",
    ],
    preparation: `Heat a pot over medium heat and sauté diced onions in a little olive oil for 2-3 minutes until soft.
Add the diced carrots and celery to the pot and stir occasionally for 3-4 minutes.
Pour in the vegetable broth and bring the mixture to a simmer.
Let the soup simmer for 15 minutes until the vegetables are tender.
Season with salt, pepper, and herbs like thyme or rosemary to taste.
Stir the soup well, ensuring all vegetables are cooked.
Serve hot with a slice of whole-grain bread for a wholesome meal.`,
  },
  {
    mealTime: "LUNCH",
    name: "Baked Sweet Potato",
    kiloCaloriesBurnt: 300,
    timeTaken: "30",
    imagePath: "https://minimalistbaker.com/wp-content/uploads/2014/09/Mediterranean-Baked-Sweet-Potatoes-A-healthy-30-minute-meal-thats-flavorful-and-satisfying-vegan-glutenfree.jpg",
    ingredients: ["1 medium sweet potato", "1 tsp butter"],
    preparation: `Preheat the oven to 375°F (190°C) and line a baking tray with parchment paper.
Wash the sweet potato thoroughly under cold water and pat it dry with a towel.
Pierce the sweet potato a few times with a fork to allow steam to escape while baking.
Place the sweet potato on the baking tray and bake for 25-30 minutes, or until tender when pierced with a fork.
Once baked, cut the sweet potato open and fluff the inside with a fork.
Add a small amount of butter and season with salt and pepper to taste.
For extra flavor, top with cinnamon or a drizzle of honey before serving.`,
  },
  {
    mealTime: "SNACK",
    name: "Cheese Crackers",
    kiloCaloriesBurnt: 300,
    timeTaken: "5",
    imagePath: "https://media.istockphoto.com/id/180103076/photo/cheese-and-crackers.jpg?s=612x612&w=0&k=20&c=HlNW0CVu1ICYS1LhJitJFaQEbvQO_1ES4GC-eb1nKDY=",
    ingredients: ["5 whole-grain crackers", "1 slice of cheddar cheese"],
    preparation: `Place the crackers on a plate or serving tray.
Slice the cheddar cheese into thin pieces that will fit on top of the crackers.
Place a slice of cheese on each cracker.
For added flavor, drizzle with a small amount of honey or top with a few fresh herbs.
Serve immediately as a quick and satisfying snack.`,
  },
  // 400 kcal
  {
    mealTime: "BREAKFAST",
    name: "Chicken Caesar Salad",
    kiloCaloriesBurnt: 400,
    timeTaken: "15",
    imagePath: "https://img.freepik.com/premium-photo/home-made-chicken-caesar-salad_665346-161553.jpg?semt=ais_hybrid",
    ingredients: [
      "1 grilled chicken breast",
      "2 cups romaine lettuce",
      "2 tbsp Caesar dressing",
      "1/4 cup croutons",
      "1 tbsp grated Parmesan cheese",
    ],
    preparation: `Begin by grilling the chicken breast on medium heat for about 6-8 minutes on each side until cooked through.
Slice the grilled chicken into strips and set aside.
In a large bowl, toss the romaine lettuce with Caesar dressing, ensuring the lettuce is well-coated.
Add the grilled chicken strips to the top of the salad.
Sprinkle croutons and grated Parmesan cheese over the salad for crunch and flavor.
Toss the salad gently to combine all the ingredients.
Serve immediately as a hearty and fulfilling lunch or dinner.`,
  },
  {
    mealTime: "LUNCH",
    name: "Stuffed Bell Peppers",
    kiloCaloriesBurnt: 400,
    timeTaken: "25",
    imagePath: "https://media.istockphoto.com/id/1409751973/photo/stuffed-peppers.jpg?s=612x612&w=0&k=20&c=qJ35lYQeq-rQmnnQJadrIvOSvgVMq4pA3z0jlZeiwHY=",
    ingredients: [
      "2 bell peppers",
      "1/2 cup cooked quinoa",
      "1/4 cup black beans",
      "1/4 cup diced tomatoes",
      "1 tsp cumin",
      "1 tbsp olive oil",
    ],
    preparation: `Preheat the oven to 375°F (190°C) and line a baking sheet with parchment paper.
Cut the tops off the bell peppers and remove the seeds and membranes.
In a bowl, combine the cooked quinoa, black beans, diced tomatoes, and cumin.
Stuff the bell peppers with the quinoa mixture, pressing down gently to pack it in.
Drizzle a little olive oil over the stuffed peppers and place them on the baking sheet.
Bake for 20 minutes, or until the peppers are tender and slightly charred on the edges.
Serve hot, garnished with fresh cilantro or a dollop of Greek yogurt if desired.`,
  },
  {
    mealTime: "SNACK",
    name: "Greek Yogurt ",
    kiloCaloriesBurnt: 400,
    timeTaken: "5",
    imagePath: "https://www.kitchenfrau.com/wp-content/uploads/2013/07/IMG_7806-682x1024.jpg",
    ingredients: [
      "1 cup Greek yogurt",
      "1 tbsp honey",
      "1/4 cup mixed nuts",
    ],
    preparation: `Spoon the Greek yogurt into a bowl, smoothing the top with the back of a spoon.
Drizzle honey over the yogurt, making sure to cover the entire surface.
Top with mixed nuts, such as almonds, walnuts, and pistachios, for a crunchy texture.
Serve immediately or refrigerate for a chilled snack.`,
  },
  // 500 kcal
  {
    mealTime: "BREAKFAST",
    name: "Avocado Toast with Egg",
    kiloCaloriesBurnt: 500,
    timeTaken: "10",
    imagePath: "https://t3.ftcdn.net/jpg/09/28/33/44/360_F_928334476_kiUomUPjV5GrfVVgykVd3rskVLe0KAOL.jpg",
    ingredients: [
      "1 slice whole grain bread",
      "1/2 ripe avocado",
      "1 boiled egg",
      "Salt and pepper to taste",
      "Lemon juice (optional)",
    ],
    preparation: `Toast the whole grain bread until golden and crispy.
Cut the avocado in half, remove the pit, and scoop the flesh into a bowl.
Mash the avocado with a fork and season with a pinch of salt, pepper, and a few drops of lemon juice.
Spread the mashed avocado evenly on the toasted bread.
Peel and slice the boiled egg, placing the slices on top of the avocado toast.
Sprinkle additional salt and pepper on top if desired.
Serve immediately as a hearty and nutritious breakfast.`,
  },
  {
    mealTime: "LUNCH",
    name: "Grilled Chicken Quinoa Salad",
    kiloCaloriesBurnt: 500,
    timeTaken: "20",
    imagePath: "https://pinchofyum.com/wp-content/uploads/Chicken-Quinoa-Salad-4.jpg",
    ingredients: [
      "1 grilled chicken breast",
      "1/2 cup cooked quinoa",
      "1 cup mixed greens",
      "1/4 cup cherry tomatoes",
      "1 tbsp olive oil",
      "1 tbsp balsamic vinegar",
      "Salt and pepper to taste",
    ],
    preparation: `Grill the chicken breast on medium heat for about 6-8 minutes per side until cooked through.
Slice the grilled chicken into thin strips.
In a large bowl, combine the cooked quinoa and mixed greens.
Add cherry tomatoes, olive oil, and balsamic vinegar to the salad.
Top with the grilled chicken slices and toss gently to combine all the ingredients.
Season with salt and pepper to taste.
Serve immediately as a filling lunch or dinner option.`,
  },
  {
    mealTime: "SNACK",
    name: "Protein Smoothie",
    kiloCaloriesBurnt: 500,
    timeTaken: "5",
    imagePath: "https://www.eatingwell.com/thmb/rCi_NzVLQIuhidCXL3U30M3Gp1A=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/Almond-Butter-Banana-Protein-Smoothie-b6793d5265c442f98344110b458a4524.jpg",
    ingredients: [
      "1 banana",
      "1 scoop protein powder",
      "1/2 cup almond milk",
      "1/4 cup Greek yogurt",
      "1 tsp peanut butter",
    ],
    preparation: `Peel the banana and add it to a blender.
Add the protein powder, almond milk, Greek yogurt, and peanut butter to the blender.
Blend until smooth and creamy, adding more almond milk if needed for a thinner consistency.
Pour into a glass and serve immediately as a post-workout snack or a quick energy boost.`,
  },
  // 600 kcal
  {
    mealTime: "BREAKFAST",
    name: "Peanut Butter Banana Toast",
    kiloCaloriesBurnt: 600,
    timeTaken: "5",
    imagePath: "https://www.wellplated.com/wp-content/uploads/2014/08/Peanut-Butter-Banana-Honey-Toast-with-Granola-Crunch.jpg",
    ingredients: [
      "2 slices whole grain bread",
      "2 tbsp peanut butter",
      "1 banana",
      "1 tsp honey (optional)",
    ],
    preparation: `Toast the bread slices until crispy and golden.
Spread peanut butter evenly on each slice of toast.
Slice the banana into thin rounds and arrange the slices on top of the peanut butter.
Drizzle honey on top for added sweetness if desired.
Serve immediately as a quick and delicious breakfast.`,
  },
  {
    mealTime: "LUNCH",
    name: "Grilled Salmon Vegetables",
    kiloCaloriesBurnt: 600,
    timeTaken: "25",
    imagePath: "https://gardeninthekitchen.com/wp-content/uploads/2023/05/salmon-in-foil-with-vegetables_3854.jpg",
    ingredients: [
      "1 salmon fillet",
      "1 cup mixed vegetables (carrots, zucchini, bell peppers)",
      "1 tbsp olive oil",
      "1 tsp lemon juice",
      "Salt and pepper to taste",
    ],
    preparation: `Preheat the oven to 375°F (190°C).
Toss the mixed vegetables in olive oil, salt, and pepper, and spread them out evenly on a baking tray.
Place the salmon fillet on the same tray, drizzling with lemon juice and seasoning with salt and pepper.
Roast everything in the oven for 20-25 minutes, or until the salmon is cooked through and the vegetables are tender.
Serve the salmon and roasted vegetables hot for a fulfilling lunch.`,
  },
  {
    mealTime: "SNACK",
    name: "Hummus and Carrot Sticks",
    kiloCaloriesBurnt: 600,
    timeTaken: "5",
    imagePath: "https://images.immediate.co.uk/production/volatile/sites/30/2020/08/recipe-image-legacy-id-1259475_8-0b45ac8.jpg?quality=90&resize=440,400",
    ingredients: [
      "1/4 cup hummus",
      "1 large carrot",
    ],
    preparation: `Peel and slice the carrot into thin sticks.
Spoon the hummus into a small bowl for dipping.
Serve the carrot sticks with the hummus for a crunchy, healthy snack.`,
  },
  // 700 kcal
  {
    mealTime: "BREAKFAST",
    name: "Oatmeal with Almonds Berries",
    kiloCaloriesBurnt: 700,
    timeTaken: "10",
    imagePath: "https://i2.wp.com/www.downshiftology.com/wp-content/uploads/2022/12/How-To-Make-Berry-Baked-Oatmeal-8.jpg",
    ingredients: [
      "1/2 cup rolled oats",
      "1 cup almond milk",
      "1/4 cup mixed berries",
      "2 tbsp chopped almonds",
      "1 tbsp maple syrup",
    ],
    preparation: `In a pot, combine the rolled oats and almond milk. Bring to a boil, then reduce heat and simmer for about 5 minutes, stirring occasionally.
Once the oats are cooked and creamy, pour into a bowl.
Top with mixed berries, chopped almonds, and a drizzle of maple syrup.
Serve immediately as a hearty and nutritious breakfast.`,
  },
  {
    mealTime: "LUNCH",
    name: "Turkey and Avocado Wrap",
    kiloCaloriesBurnt: 700,
    timeTaken: "15",
    imagePath: "https://i0.wp.com/undomesticmom.com/wp-content/uploads/2019/01/2018-10-14-12.55.16.jpg?resize=453,500&ssl=1",
    ingredients: [
      "1 whole-grain tortilla",
      "4 oz sliced turkey breast",
      "1/2 avocado",
      "1/4 cup spinach leaves",
      "1 tbsp mustard or mayonnaise",
    ],
    preparation: `Place the whole-grain tortilla on a flat surface.
Layer the tortilla with sliced turkey breast, avocado slices, spinach leaves, and mustard or mayonnaise.
Roll up the tortilla tightly, folding in the sides as you go to form a wrap.
Serve immediately or wrap in foil for a lunch on the go.`,
  },
  {
    mealTime: "SNACK",
    name: "Chia Seed Pudding",
    kiloCaloriesBurnt: 700,
    timeTaken: "5",
    imagePath: "https://i0.wp.com/kristineskitchenblog.com/wp-content/uploads/2023/12/easy-chia-pudding-04.jpg?resize=1400,2100&ssl=1",
    ingredients: [
      "3 tbsp chia seeds",
      "1 cup almond milk",
      "1 tsp vanilla extract",
      "1 tbsp honey",
    ],
    preparation: `In a small bowl, combine the chia seeds, almond milk, vanilla extract, and honey.
Stir well and cover the bowl with plastic wrap.
Refrigerate for at least 2 hours or overnight to allow the chia seeds to expand and form a pudding-like texture.
Serve chilled with a topping of fresh fruit or nuts if desired.`,
  },
  // 800 kcal
  {
    mealTime: "BREAKFAST",
    name: "Scrambled Eggs with Avocado",
    kiloCaloriesBurnt: 800,
    timeTaken: "15",
    imagePath: "https://cdn.prod.website-files.com/61846b3b19bf2706cbeb504a/641a0e7056dade87cd4bdd58_Scrambled%20Eggs%20with%20Spinach%20and%20Avocado.webp",
    ingredients: [
      "3 large eggs",
      "1/2 avocado",
      "1 tbsp butter",
      "Salt and pepper to taste",
    ],
    preparation: `In a bowl, whisk the eggs and season with salt and pepper.
Melt butter in a non-stick skillet over medium heat.
Pour the eggs into the skillet and stir gently, allowing the eggs to scramble.
Slice the avocado and serve alongside the scrambled eggs.
Serve immediately for a filling and nutritious breakfast.`,
  },
  {
    mealTime: "LUNCH",
    name: "Beef Stirfry with Rice",
    kiloCaloriesBurnt: 800,
    timeTaken: "20",
    imagePath: "https://www.howsweeteats.com/wp-content/uploads/2014/02/chili-garlic-beef-I-howsweeteats.com-4.jpg",
    ingredients: [
      "4 oz beef (sirloin or flank steak)",
      "1/2 cup cooked rice",
      "1 cup mixed vegetables (bell peppers, onions, broccoli)",
      "2 tbsp soy sauce",
      "1 tbsp olive oil",
    ],
    preparation: `Slice the beef into thin strips.
Heat olive oil in a pan over medium-high heat. Add the beef and cook for 4-5 minutes until browned.
Add the mixed vegetables to the pan and stir-fry for an additional 5 minutes until tender.
Pour in the soy sauce and stir to coat everything evenly.
Serve the stir-fry over the cooked rice for a complete meal.`,
  },
  {
    mealTime: "SNACK",
    name: "Greek Yogurt Parfait",
    kiloCaloriesBurnt: 800,
    timeTaken: "5",
    imagePath: "https://www.wellplated.com/wp-content/uploads/2024/05/How-to-Make-a-Yogurt-Parfait-4.jpg",
    ingredients: [
      "1 cup Greek yogurt",
      "1/4 cup granola",
      "1/4 cup mixed berries",
      "1 tbsp honey",
    ],
    preparation: `Layer the Greek yogurt, granola, and mixed berries in a bowl or glass.
Drizzle honey over the top for added sweetness.
Serve immediately as a satisfying snack or dessert.`,
  },
  // 900 kcal
  {
    mealTime: "BREAKFAST",
    name: "Pancakes with Maple Syrup",
    kiloCaloriesBurnt: 900,
    timeTaken: "20",
    imagePath: "https://www.giallozafferano.com/images/260-26079/Pancakes-with-maple-syrup_1200x800.jpg",
    ingredients: [
      "1 cup all-purpose flour",
      "1/2 cup milk",
      "1 egg",
      "1 tbsp sugar",
      "1 tbsp baking powder",
      "2 tbsp butter",
      "Maple syrup for topping",
    ],
    preparation: `In a mixing bowl, combine the flour, sugar, and baking powder.
Whisk in the milk, egg, and melted butter until smooth.
Heat a griddle or pan over medium heat and lightly grease it with butter.
Pour 1/4 cup of the batter onto the griddle for each pancake and cook for 2-3 minutes on each side until golden.
Stack the pancakes and drizzle with maple syrup.
Serve immediately for a delicious breakfast.`,
  },
  {
    mealTime: "LUNCH",
    name: "Chicken Caesar Salad",
    kiloCaloriesBurnt: 900,
    timeTaken: "15",
    imagePath: "https://media.gettyimages.com/id/1449130376/photo/chicken-caesar-salad.jpg?s=612x612&w=0&k=20&c=ACBipXGzKWlmMzgfr0aMZBroejYvMu0_T6pQ4YuSZCU=",
    ingredients: [
      "1 grilled chicken breast",
      "2 cups Romaine lettuce",
      "1/4 cup grated Parmesan cheese",
      "1/4 cup Caesar dressing",
      "Croutons",
    ],
    preparation: `Grill the chicken breast and slice it into thin strips.
In a large bowl, combine the Romaine lettuce, grated Parmesan cheese, and croutons.
Toss the salad with Caesar dressing to coat everything evenly.
Top with the grilled chicken slices.
Serve immediately for a classic and satisfying lunch.`,
  },
  {
    mealTime: "SNACK",
    name: "Chocolate Protein Bars",
    kiloCaloriesBurnt: 900,
    timeTaken: "10",
    imagePath: "https://www.ambitiouskitchen.com/wp-content/uploads/2017/12/Peanut-Butter-Cup-Protein-Bars-6-594x594.jpg",
    ingredients: [
      "1 cup oats",
      "1/4 cup protein powder",
      "1/4 cup peanut butter",
      "2 tbsp honey",
      "2 tbsp cocoa powder",
    ],
    preparation: `In a bowl, combine oats, protein powder, cocoa powder, and honey.
Stir in peanut butter and mix until everything is well combined.
Press the mixture into a baking dish lined with parchment paper.
Refrigerate for 1-2 hours to set.
Cut into bars and serve as a high-protein snack.`,
  },
  // 1000 kcal
  {
    mealTime: "BREAKFAST",
    name: "Breakfast Burrito",
    kiloCaloriesBurnt: 1000,
    timeTaken: "15",
    imagePath: "https://media.istockphoto.com/id/157650059/photo/breakfast-burrito-with-scrambled-eggs.jpg?s=612x612&w=0&k=20&c=bvCOuDfFOnzZJf95sLNR7E9fosEdVofWimCMh8Tx2UA=",
    ingredients: [
      "1 large flour tortilla",
      "3 scrambled eggs",
      "2 oz shredded cheese",
      "1/4 cup black beans",
      "1/4 cup salsa",
      "1 tbsp sour cream",
    ],
    preparation: `Scramble the eggs in a skillet over medium heat.
Warm the tortilla in a separate pan for about 30 seconds.
Layer the scrambled eggs, cheese, black beans, salsa, and sour cream onto the center of the tortilla.
Roll up the tortilla to form a burrito, folding in the sides.
Serve immediately as a hearty breakfast.`,
  },
  {
    mealTime: "LUNCH",
    name: "Chicken Alfredo Pasta",
    kiloCaloriesBurnt: 1000,
    timeTaken: "25",
    imagePath: "https://thecozycook.com/wp-content/uploads/2022/08/Chicken-Alfredo-Pasta-2.jpg",
    ingredients: [
      "1 chicken breast",
      "1/2 cup fettuccine pasta",
      "1/4 cup heavy cream",
      "1/4 cup grated Parmesan cheese",
      "1 tbsp butter",
      "1 clove garlic",
    ],
    preparation: `Cook the fettuccine pasta according to package instructions.
In a skillet, melt the butter and sauté garlic until fragrant.
Add the chicken breast and cook until browned on both sides. Slice into thin strips.
Add heavy cream to the skillet and simmer until thickened.
Stir in grated Parmesan cheese to make the sauce creamy.
Toss the pasta with the creamy sauce and top with the sliced chicken.
Serve immediately for a rich and filling lunch.`,
  },
  {
    mealTime: "SNACK",
    name: "Trail Mix",
    kiloCaloriesBurnt: 1000,
    timeTaken: "5",
    imagePath: "https://media.istockphoto.com/id/483585729/photo/trail-mix-on-white.jpg?s=612x612&w=0&k=20&c=NF62K238GBFUXlGdPQj9hSnstNYytACFthHqOUtAhqI=",
    ingredients: [
      "1/2 cup mixed nuts (almonds, cashews, walnuts)",
      "1/4 cup dried fruit (raisins, cranberries)",
      "1/4 cup dark chocolate chips",
    ],
    preparation: `Combine the mixed nuts, dried fruit, and dark chocolate chips in a bowl.
Stir to mix evenly.
Serve immediately as a quick, energizing snack.`,
  },

];

// Dynamic Meal Filtering Based on Calories
app.get("/meals/:kcalLeft", (req, res) => {
  const kcalLeft = parseInt(req.params.kcalLeft, 10);

  // Filter meals based on the remaining calories
  const filteredMeals = meals.filter((meal) => meal.kiloCaloriesBurnt <= kcalLeft);

  // Respond with the filtered list
  res.status(200).json(filteredMeals);
});

const workouts = [
  // 100 kcal
  { 
    name: "Light Bench Press", 
    instruction: "3 sets of 10 reps", 
    kcal: 100 
  },
  { 
    name: "Assisted Pull-ups", 
    instruction: "3 sets of 12 reps", 
    kcal: 100 
  },
  { 
    name: "Light Biceps Curl", 
    instruction: "3 sets of 12 reps", 
    kcal: 100 
  },

  // 200 kcal
  { 
    name: "Moderate Dumbbell Press", 
    instruction: "4 sets of 8 reps", 
    kcal: 200 
  },
  { 
    name: "Deadlift Basics", 
    instruction: "3 sets of 6 reps", 
    kcal: 200 
  },
  { 
    name: "Hammer Curl", 
    instruction: "3 sets of 10 reps", 
    kcal: 200 
  },

  // 300 kcal
  { 
    name: "Intense Pull-ups", 
    instruction: "4 sets of 8 reps", 
    kcal: 300 
  },
  { 
    name: "Heavy Bench Press", 
    instruction: "4 sets of 5 reps", 
    kcal: 300 
  },
  { 
    name: "Incline Biceps Curl", 
    instruction: "4 sets of 10 reps", 
    kcal: 300 
  },

  // 400 kcal
  { 
    name: "Full Body Dips", 
    instruction: "4 sets of 10 reps", 
    kcal: 400 
  },
  { 
    name: "Wide Grip Lat Pulldown", 
    instruction: "3 sets of 12 reps", 
    kcal: 400 
  },
  { 
    name: "Concentration Curl", 
    instruction: "3 sets of 10 reps", 
    kcal: 400 
  },

  // 500 kcal
  { 
    name: "Advanced Deadlift", 
    instruction: "4 sets of 4 reps", 
    kcal: 500 
  },
  { 
    name: "Incline Bench Press", 
    instruction: "4 sets of 6 reps", 
    kcal: 500 
  },
  { 
    name: "Barbell Biceps Curl", 
    instruction: "4 sets of 8 reps", 
    kcal: 500 
  },

  // 600 kcal
  { 
    name: "Progressive Pull-ups", 
    instruction: "5 sets of 6 reps", 
    kcal: 600 
  },
  { 
    name: "Decline Dumbbell Press", 
    instruction: "4 sets of 8 reps", 
    kcal: 600 
  },
  { 
    name: "Cable Biceps Curl", 
    instruction: "4 sets of 10 reps", 
    kcal: 600 
  },

  // 700 kcal
  { 
    name: "Explosive Dips", 
    instruction: "5 sets of 12 reps", 
    kcal: 700 
  },
  { 
    name: "Close Grip Lat Pulldown", 
    instruction: "4 sets of 10 reps", 
    kcal: 700 
  },
  { 
    name: "EZ Bar Curl", 
    instruction: "4 sets of 12 reps", 
    kcal: 700 
  },

  // 800 kcal
  { 
    name: "Power Deadlift", 
    instruction: "4 sets of 3 reps", 
    kcal: 800 
  },
  { 
    name: "Heavy Incline Press", 
    instruction: "4 sets of 5 reps", 
    kcal: 800 
  },
  { 
    name: "Preacher Curl", 
    instruction: "4 sets of 8 reps", 
    kcal: 800 
  },

  // 900 kcal
  { 
    name: "Max Effort Pull-ups", 
    instruction: "6 sets of 5 reps", 
    kcal: 900 
  },
  { 
    name: "Weighted Bench Press", 
    instruction: "5 sets of 4 reps", 
    kcal: 900 
  },
  { 
    name: "Concentration Hammer Curl", 
    instruction: "5 sets of 6 reps", 
    kcal: 900 
  },

  // 1000 kcal
  { 
    name: "Extreme Deadlift", 
    instruction: "5 sets of 2 reps", 
    kcal: 1000 
  },
  { 
    name: "Ultimate Dumbbell Press", 
    instruction: "5 sets of 6 reps", 
    kcal: 1000 
  },
  { 
    name: "Ultimate Biceps Curl", 
    instruction: "5 sets of 5 reps", 
    kcal: 1000 
  },
];

  

// Endpoint to get workouts filtered by kcalLeft
app.get("/workouts/:kcalLeft", (req, res) => {
  const kcalLeft = parseInt(req.params.kcalLeft, 10);
  
  // Filter workouts based on kcalLeft
  const filteredWorkouts = workouts.filter((workout) => workout.kcal <= kcalLeft);
  
  // Respond with filtered workouts
  res.status(200).json(filteredWorkouts);
});



// Update user profile
app.put('/update-profile', async (req, res) => {
  try {
    const { username, age, hobby, height, weight, password,image } = req.body;

    const user = await User.findOneAndUpdate(
      { username },
      { age, hobby, height, weight,password,image },
      { new: true } // Return the updated document
    );

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: 'Profile updated successfully', user });
  } catch (error) {
    console.error('Error updating user profile:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});


// Start the server
app.listen(port, "0.0.0.0", () => {
  console.log(`Server running on http://0.0.0.0:${port}`); // Open for all network interfaces
});
