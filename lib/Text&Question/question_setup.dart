import 'package:flutter/material.dart';
import 'generate_questions.dart';
import 'question_display.dart';
import '../database.dart';
import 'pdf_text.dart';

class QuestionSetupScreen extends StatefulWidget {
  final String pdfPath;

  QuestionSetupScreen({required this.pdfPath});

  @override
  _QuestionSetupScreenState createState() => _QuestionSetupScreenState();
}

class _QuestionSetupScreenState extends State<QuestionSetupScreen> {
  String _difficulty = 'Easy';
  final TextEditingController _nameController = TextEditingController();
  bool _isNameValid = true;

  // Marking this method as async to use await
  Future<void> _generateQuestions() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _isNameValid = false;
      });
      return;
    }

    setState(() {
      _isNameValid = true;
    });

    try {
      // Await the extraction of text from PDF
      String extractedText = await PDFTextExtractor.extractText(widget.pdfPath);
      if (extractedText.contains('Error processing PDF file') ||
          extractedText.contains('The PDF file contains too much text')) {
        _showErrorDialog(extractedText);
        return;
      }

      if (PDFTextExtractor.containsTurkishCharacters(extractedText)) {
        _showTurkishWarningDialog(extractedText);
      } else {
        // Proceed with question generation if no warnings
        await _proceedWithQuestionGeneration(extractedText);
      }
    } catch (e) {
      _showErrorDialog('An unexpected error occurred: $e');
    }
  }

  // Marking this method as async to use await
  Future<void> _proceedWithQuestionGeneration(String extractedText) async {
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

    try {
      QuestionGenerator generator = QuestionGenerator(
        pdfPath: widget.pdfPath,
        numberOfQuestions: 10,
        difficulty: _difficulty,
      );
      List<Map<String, dynamic>> generatedQuestions = await generator.generateQuestions();
      await DatabaseHelper().insertModule({
        'name': _nameController.text,
        'difficulty': _difficulty,
        'questionCount': 10,
        'pdfPath': widget.pdfPath,
      });

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionDisplayScreen(
            pdfPath: widget.pdfPath,
            difficulty: _difficulty,
            numberOfQuestions: 10,
            name: _nameController.text,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('An unexpected error occurred while generating questions: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTurkishWarningDialog(String extractedText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Warning'),
        content: Text('The PDF file contains Turkish characters. You may receive inaccurate questions.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedWithQuestionGeneration(extractedText);
            },
            child: Text('Continue Anyway'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Setup Questions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Difficulty',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: _difficulty,
              items: ['Easy', 'Medium', 'Hard'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _difficulty = newValue!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 24.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                errorText: _isNameValid ? null : 'Name is required',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _generateQuestions,
                child: Text(
                  'Generate Questions',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  textStyle: TextStyle(fontSize: 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
