import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_selector/file_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Main Screen/pdf_view.dart';
import 'database.dart';
import 'Text&Question/question_display.dart';
import 'Text&Question/question_setup.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduQuest',
      theme: _isDarkTheme ? darkTheme : lightTheme,
      home: AnimatedSplashScreen(
        splash: Text(
          'EduQuest',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
            color: Colors.white,
          ),
        ),
        nextScreen: LoginScreen(),
        splashTransition: SplashTransition.fadeTransition,
        pageTransitionType: PageTransitionType.fade,
        backgroundColor: Colors.teal,
        duration: 3000,
      ),
    );
  }
}

ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.teal,
  brightness: Brightness.light,
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: Colors.white,
);

ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.teal,
  brightness: Brightness.dark,
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: Colors.grey[900],
);

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> modules = [];
  final List<Color> colors = [
    Colors.green[200]!,
    Colors.blue[200]!,
    Colors.red[200]!,
    Colors.orange[200]!,
    Colors.purple[200]!,
  ];

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    final data = await DatabaseHelper().queryAllModules();
    setState(() {
      modules = data;
    });
  }

  Future<void> _pickPDF() async {
    final typeGroup = XTypeGroup(
      label: 'PDFs',
      extensions: ['pdf'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewScreen(pdfPath: file.path),
        ),
      ).then((_) => _loadModules());
    }
  }

  void _showEditDeleteOptions(Map<String, dynamic> module) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Delete Modal',
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: EditDeleteModal(
              module: module,
              onModuleUpdated: _loadModules,
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -1),
            end: Offset(0, 0),
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  void _showDifficultySelection(Map<String, dynamic> module) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DifficultySelectionModal(module: module);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'EduQuest',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white, size: 30.0),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.teal,
          child: Column(
            children: <Widget>[
              SizedBox(height: 50),
              ListTile(
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {},
              ),
              Spacer(),
              ListTile(
                leading: Icon(Icons.person, color: Colors.white, size: 30),
                title: Text('Profile', style: TextStyle(color: Colors.white, fontSize: 20)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white, size: 30),
                title: Text('Settings', style: TextStyle(color: Colors.white, fontSize: 20)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.white, size: 30),
                title: Text('About', style: TextStyle(color: Colors.white, fontSize: 20)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutScreen()),
                  );
                },
              ),
              Spacer(),
            ],
          ),
        ),
      ),
      body: modules.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No tests available. Select a PDF to create one.',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickPDF,
              child: Text('Select PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: modules.length,
              controller: PageController(viewportFraction: 0.9),
              itemBuilder: (context, index) {
                final module = modules[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: InkWell(
                    onTap: () => _showDifficultySelection(module),
                    onLongPress: () => _showEditDeleteOptions(module),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            module['name'],
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tap to retake the quiz.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: _pickPDF,
                child: Text('Select PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditDeleteModal extends StatefulWidget {
  final Map<String, dynamic> module;
  final VoidCallback onModuleUpdated;

  EditDeleteModal({required this.module, required this.onModuleUpdated});

  @override
  _EditDeleteModalState createState() => _EditDeleteModalState();
}

class _EditDeleteModalState extends State<EditDeleteModal> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.module['name'];
  }

  Future<void> _updateModule() async {
    final updatedModule = {
      'id': widget.module['id'],
      'name': _nameController.text,
      'difficulty': widget.module['difficulty'],
      'questionCount': widget.module['questionCount'],
      'pdfPath': widget.module['pdfPath'],
    };
    await DatabaseHelper().updateModule(updatedModule);
    widget.onModuleUpdated();
    Navigator.pop(context);
  }

  Future<void> _deleteModule() async {
    await DatabaseHelper().deleteModule(widget.module['id']);
    widget.onModuleUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit or Delete Module',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Module Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateModule,
              child: Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _deleteModule,
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DifficultySelectionModal extends StatefulWidget {
  final Map<String, dynamic> module;

  DifficultySelectionModal({required this.module});

  @override
  _DifficultySelectionModalState createState() => _DifficultySelectionModalState();
}

class _DifficultySelectionModalState extends State<DifficultySelectionModal> {
  String _selectedDifficulty = 'Easy';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Difficulty',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          DropdownButton<String>(
            value: _selectedDifficulty,
            items: <String>['Easy', 'Medium', 'Hard'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedDifficulty = newValue!;
              });
            },
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              showLoadingDialog(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionDisplayScreen(
                    pdfPath: widget.module['pdfPath'],
                    difficulty: _selectedDifficulty,
                    numberOfQuestions: widget.module['questionCount'],
                    name: widget.module['name'],
                  ),
                ),
              ).then((_) {
                Navigator.pop(context);
              });
            },
            child: Text('Retake Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Please wait',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          Text('Your questions are being prepared...'),
        ],
      ),
    ),
  );
}
