import 'package:flutter/material.dart';
import 'database.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dbHelper = DatabaseHelper();

  Future<void> _register() async {
    final email = _emailController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match');
      return;
    }

    if (!_isValidUsername(username)) {
      _showSnackBar('Username can only contain lowercase letters, numbers, and underscores');
      return;
    }

    if (username.contains(' ')) {
      _showSnackBar('Username must be written as one word');
      return;
    }

    final user = await _dbHelper.getUser(email);
    final userByUsername = await _dbHelper.getUser(username);
    if (user == null && userByUsername == null) {
      await _dbHelper.insertUser({'email': email, 'username': username, 'password': password});
      _showSnackBar('Account created successfully');
      Navigator.pop(context);
    } else {
      _showSnackBar('Email or Username already exists');
    }
  }

  bool _isValidUsername(String username) {
    return RegExp(r'^[a-z0-9_]+$').hasMatch(username);
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
              _buildTextField(_emailController, 'Email'),
              SizedBox(height: 16),
              _buildTextField(_usernameController, 'Username'),
              SizedBox(height: 16),
              _buildTextField(_passwordController, 'Password', obscureText: true),
              SizedBox(height: 16),
              _buildTextField(_confirmPasswordController, 'Confirm Password', obscureText: true),
              SizedBox(height: 20),
              _buildElevatedButton('Register', _register),
              _buildTextButton('Back to Login', () => Navigator.pop(context)),
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
