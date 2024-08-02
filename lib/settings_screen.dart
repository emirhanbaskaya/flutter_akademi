import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'database.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkTheme = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  String _currentUsername = "";
  DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });

    String? email = prefs.getString('email');
    if (email != null) {
      Map<String, dynamic>? user = await _dbHelper.getUser(email);
      if (user != null) {
        setState(() {
          _emailController.text = user['email'];
          _usernameController.text = user['username'];
          _currentUsername = user['username'];
        });
      }
    }
  }

  Future<void> _updateUser() async {
    final email = _emailController.text;
    final username = _usernameController.text;

    final user = await _dbHelper.getUser(email);
    if (user != null) {
      Map<String, dynamic> updatedUser = Map.from(user);
      updatedUser['email'] = email;
      updatedUser['username'] = username;
      await _dbHelper.updateUser(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User information updated')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found')),
      );
    }
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    await _updateUser();
    setState(() {}); // Update UI to reflect theme change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkTheme ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          TextButton(
            onPressed: () {
              _saveSettings();
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text(
              'Signed in as',
              style: TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              _currentUsername,
              style: TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
            ),
          ),
          Divider(color: _isDarkTheme ? Colors.grey : Colors.black),
          ListTile(
            title: Text(
              'Change Username',
              style: TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
            ),
            onTap: () => _changeUsernameDialog(),
          ),
          ListTile(
            title: Text(
              'Change Email',
              style: TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
            ),
            onTap: () => _changeEmailDialog(),
          ),
          ListTile(
            title: Text(
              'Change Password',
              style: TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
            ),
            onTap: () => _changePasswordDialog(),
          ),
          SwitchListTile(
            title: Text(
              'Dark Theme',
              style: TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
            ),
            value: _isDarkTheme,
            onChanged: (bool value) {
              setState(() {
                _isDarkTheme = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void _changeUsernameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Username'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'New Username',
              labelStyle: TextStyle(color: Colors.grey),
            ),
            style: TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Change'),
              onPressed: () {
                _updateUser();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changeEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Email'),
          content: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'New Email',
              labelStyle: TextStyle(color: Colors.grey),
            ),
            style: TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Change'),
              onPressed: () {
                _updateUser();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changePasswordDialog() {
    TextEditingController _newPasswordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                obscureText: true,
                style: TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                obscureText: true,
                style: TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Change'),
              onPressed: () async {
                if (_newPasswordController.text == _confirmPasswordController.text) {
                  final user = await _dbHelper.getUser(_emailController.text);
                  if (user != null) {
                    Map<String, dynamic> updatedUser = Map.from(user);
                    updatedUser['password'] = _newPasswordController.text;
                    await _dbHelper.updateUser(updatedUser);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password updated')),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User not found')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Passwords do not match')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
