import 'package:flutter/material.dart';
import '../Text&Question/generate_questions.dart'; // QuestionGenerator'ü import edin
import '../Text&Question/question_display.dart'; // QuestionDisplayScreen'i import edin

class DifficultySelectionModal extends StatefulWidget {
  final Map<String, dynamic> module;

  DifficultySelectionModal({required this.module});

  @override
  _DifficultySelectionModalState createState() => _DifficultySelectionModalState();
}

class _DifficultySelectionModalState extends State<DifficultySelectionModal> {
  String _selectedDifficulty = 'Easy';

  Future<void> _retakeQuiz() async {
    // Sorular hazırlanırken bir uyarı mesajı göster
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

    // Generate questions and navigate to the next screen
    QuestionGenerator generator = QuestionGenerator(
      pdfPath: widget.module['pdfPath'],
      numberOfQuestions: widget.module['questionCount'],
      difficulty: _selectedDifficulty, // zorluk seviyesi eklendi
    );
    List<Map<String, dynamic>> generatedQuestions = await generator.generateQuestions();

    // Uyarı mesajını kapat
    Navigator.pop(context);

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
    );
  }

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
            onPressed: _retakeQuiz,
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
