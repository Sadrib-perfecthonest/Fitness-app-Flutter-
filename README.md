# FlexFit

FlexFit is a fitness app that tracks your remaining kcal, protein, carbs, and fat, providing meal recommendations based on your daily goals and exercise. Built with Node.js, Express.js, MongoDB for the backend, and Flutter for the frontend, it helps you stay on track with your fitness journey.

## Packages Used

### Flutter Packages
- `cupertino_icons: ^1.0.6`
- `intl: ^0.18.1`
- `animations: ^2.0.11`
- `vector_math: ^2.1.4`
- `http: ^1.2.2`
- `mongo_dart: ^0.10.3`
- `shared_preferences: ^2.2.3`
- `image_picker: ^1.1.2`
- `fluttertoast: ^8.2.8`
- `path_provider: ^2.1.4`
- `network_info_plus: ^6.0.1`
- `flutter_screenutil: ^5.9.3`

### Node.js Packages
- `bcrypt: ^5.1.1`
- `cors: ^2.8.5`
- `express: ^4.21.2`
- `express-session: ^1.18.1`
- `jsonwebtoken: ^9.0.2`
- `mongoose: ^8.9.5`

### Server Management
- PM2 used to keep the server active automatically without manual intervention through PowerShell.

## Features
- Tracks kcal, protein, carbs, and fat intake.
- Provides meal recommendations based on the remaining calories and exercise.
- Personalized fitness goals and progress tracking.
- Easy-to-use Flutter interface for seamless user experience.
- Backend powered by Node.js, Express.js, and MongoDB for efficient data management.

## Challenges Faced
- Integration of the backend with the frontend required careful handling of HTTP requests and data parsing.
- Implementing accurate meal recommendations based on remaining calories and macronutrients.
- Ensuring the PM2 server management runs smoothly without manual intervention.
- Handling user sessions securely with JWT and Express session.

## Possible Enhancements
- Adding a feature to track water intake and other micronutrients.
- Integrating third-party APIs for enhanced meal recommendations and exercise suggestions.
- Making app more responsive.
- User notifications for meal reminders or exercise tracking.
- Cloud syncing for data persistence across multiple devices.

## Screenshots

### Splash Screen
![FlexFit splash screen](assets/screenshot1.jpeg?raw=true)
**Splash Screen - The opening screen of the app.*

### Home Screen
![FlexFit Home screen](assets/screenshot2.jpeg?raw=true)
*Home Screen - The main dashboard of the app where users can see their progress.*

### Meal Recommendations
![FlexFit Meals that recommended screen by clicking picture](assets/screenshot3.jpeg?raw=true)
*Meal Recommendations Screen - Displays meals based on the user's remaining calories.*

### Workout Screen
![FlexFit Workout by clicking buttons below Workout text](/assets/screenshot4.jpeg?raw=true)
*Workout Screen - Displays workouts that users can start by clicking on buttons below.*





## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/flexfit.git
