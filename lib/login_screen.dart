import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // Home screen import
import 'register_screen.dart'; // Register screen import
import 'database.dart'; // Database helper import

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper();

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final user = await _dbHelper.getUser(username);
    if (user != null && user['password'] == password) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', user['email']);
      _showSnackBar('Login successful');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      _showSnackBar('Invalid username or password');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'EduQuest',
                style: _textStyle(Colors.teal, 28.0, FontWeight.bold),
              ),
              SizedBox(height: 50),
              _buildTextField(_usernameController, 'Username'),
              SizedBox(height: 16),
              _buildTextField(_passwordController, 'Password', obscureText: true),
              SizedBox(height: 20),
              _buildElevatedButton('Login', _login),
              _buildTextButton('Don\'t have an account? Register', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[800],
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(fontSize: 14, color: Colors.white),
      obscureText: obscureText,
    );
  }

  TextStyle _textStyle(Color color, double fontSize, FontWeight fontWeight) {
    return TextStyle(fontFamily: 'Roboto', color: color, fontSize: fontSize, fontWeight: fontWeight);
  }

  Widget _buildElevatedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: Colors.tealAccent, fontStyle: FontStyle.italic),
      ),
    );
  }
}
