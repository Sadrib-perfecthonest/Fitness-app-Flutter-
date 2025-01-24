import 'dart:convert';
import 'dart:io';
import 'package:fitnessapp/ui/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfileScreenButton extends StatefulWidget {
  final String username;

  ProfileScreenButton({required this.username});

  @override
  _ProfileScreenButtonState createState() => _ProfileScreenButtonState();
}

class _ProfileScreenButtonState extends State<ProfileScreenButton> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController hobbyController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  File? selectedImage;

  Future<void> updateProfile() async {
    final url =
        'http://192.168.0.105:3000/update-profile'; // Replace with your server's IP

    try {
      String? base64Image;
      if (selectedImage != null) {
        base64Image = base64Encode(selectedImage!.readAsBytesSync());
      }

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'password': passwordController.text,
          'age': int.tryParse(ageController.text),
          'hobby': hobbyController.text,
          'height': double.tryParse(heightController.text),
          'weight': double.tryParse(weightController.text),
          'image': base64Image, // Send the image as a Base64 string
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $error')),
      );
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 105, 93, 143),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 105, 93, 143),
        title:
            const Text('Menu', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Update Personal Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.person, color: Colors.black),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: const Color.fromARGB(255, 114, 104, 148),
                    title: const Text('Update Profile'),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: usernameController,
                            decoration:
                                const InputDecoration(labelText: 'Username'),
                          ),
                          TextField(
                            controller: passwordController,
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                          ),
                          TextField(
                            controller: ageController,
                            decoration: const InputDecoration(labelText: 'Age'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: hobbyController,
                            decoration:
                                const InputDecoration(labelText: 'Hobby'),
                          ),
                          TextField(
                            controller: heightController,
                            decoration:
                                const InputDecoration(labelText: 'Height (cm)'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: weightController,
                            decoration:
                                const InputDecoration(labelText: 'Weight (kg)'),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: selectedImage != null
                                  ? Image.file(selectedImage!,
                                      fit: BoxFit.cover)
                                  : const Center(
                                      child: Text('Tap to select an image'),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await updateProfile();
                        },
                        child: const Text('Update'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('App Feedback',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.feedback, color: Colors.black),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  final TextEditingController feedbackController =
                      TextEditingController();

                  return AlertDialog(
                    backgroundColor: const Color.fromARGB(255, 114, 104, 148),
                    title: const Text('Submit Feedback'),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: feedbackController,
                            decoration: const InputDecoration(
                              labelText: 'Your Feedback',
                            ),
                            maxLines: 5,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          final feedback = feedbackController.text;
                          if (feedback.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Feedback submitted!')),
                            );
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter feedback')),
                            );
                          }
                        },
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                              color: Color.fromARGB(255, 73, 43, 172)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel',
                            style: TextStyle(
                                color: Color.fromARGB(255, 73, 43, 172))),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Log Out',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.logout, color: Colors.black),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Terms and Conditions',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.article, color: Colors.black),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Scaffold(
                  backgroundColor: Color.fromARGB(255, 88, 74, 136),
                  appBar: AppBar(
                    title: const Text(
                      'Terms and Conditions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Color.fromARGB(255, 88, 74, 136),
                  ),
                  body: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                        '''By using this application, you agree to the following terms and conditions. We do not take any responsibility for the use of our services, and you acknowledge that the content provided on this platform is subject to change. All intellectual property rights belong to the creators and developers of this app. You are solely responsible for your actions while using the app, including any content shared or submitted. Any violations of these terms may lead to suspension or termination of your account. Please ensure that you are following all the applicable laws in your region while using this service.''',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ));
            },
          ),
        ],
      ),
    );
  }
}
