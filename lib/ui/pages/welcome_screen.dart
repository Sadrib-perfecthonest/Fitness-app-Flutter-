import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // For Base64 encoding
import 'profile_screen.dart';
import 'package:network_info_plus/network_info_plus.dart'; // For getting device IP

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController hobbyController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String profileImage = ""; // To store the Base64 encoded string
  String localIp = "";

  @override
  void initState() {
    super.initState();
    _getLocalIp();
  }

  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        profileImage = base64Encode(bytes); // Convert image to Base64 string
      });
    }
  }

  Future<void> _getLocalIp() async {
    final NetworkInfo info = NetworkInfo();
    final ip = await info.getWifiIP();
    setState(() {
      localIp = ip ?? '';
    });
  }

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        String serverIp;

        if (localIp.isNotEmpty && localIp.startsWith("192.168")) {
          serverIp = 'http://192.168.0.105:3000/register';
        } else {
          serverIp = 'http://103.103.88.185:3000/register';
        }

        var uri = Uri.parse(serverIp);

        var response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'username': usernameController.text.trim(),
            'age': ageController.text.trim(),
            'hobby': hobbyController.text.trim(),
            'weight': weightController.text.trim(),
            'height': heightController.text.trim(),
            'dob': dobController.text.trim(),
            'password': passwordController.text.trim(),
            'profileImage': profileImage, // Send Base64 image string
          }),
        );

        if (response.statusCode == 201) {
          Fluttertoast.showToast(
            msg: "User registered successfully!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                username: usernameController.text,
                profileImage: profileImage, // Pass Base64 string
              ),
            ),
          );
        } else {
          Fluttertoast.showToast(
            msg: "Error occurred during registration",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error occurred: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> pickDateOfBirth() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 106, 91, 156),
      appBar: AppBar(
        title: Text("Register",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 106, 91, 156),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickProfileImage,
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 73, 57, 126),
                  radius: 60,
                  backgroundImage: profileImage.isNotEmpty
                      ? MemoryImage(base64Decode(profileImage))
                      : AssetImage("assets/user.png") as ImageProvider,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Tap to upload profile picture",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your username";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: "Age",
                  labelStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your age";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: hobbyController,
                decoration: InputDecoration(
                  labelText: "Hobby",
                  labelStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: "Weight (kg)",
                  labelStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: heightController,
                decoration: InputDecoration(
                  labelText: "Height (cm)",
                  labelStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: dobController,
                decoration: InputDecoration(
                  labelText: "Date of Birth",
                  labelStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                keyboardType: TextInputType.datetime,
                onTap: pickDateOfBirth,
                readOnly: true,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 88, 74, 136),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
