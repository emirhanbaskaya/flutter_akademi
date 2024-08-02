import 'package:flutter/material.dart';
import 'generate_questions.dart';
import 'question_control_screen.dart';
import '../database.dart';
import '../main.dart'; // Import HomeScreen

class QuestionDisplayScreen extends StatefulWidget {
  final String pdfPath;
  final String difficulty;
  final int numberOfQuestions;
  final String name;

  QuestionDisplayScreen({
    required this.pdfPath,
    required this.difficulty,
    required this.numberOfQuestions,
    required this.name,
  });

  @override
  _QuestionDisplayScreenState createState() => _QuestionDisplayScreenState();
}

class _QuestionDisplayScreenState extends State<QuestionDisplayScreen> {
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;
  List<String?> _selectedAnswers = List<String?>.filled(0, null);

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  Future<void> _generateQuestions() async {
    QuestionGenerator generator = QuestionGenerator(
      pdfPath: widget.pdfPath,
      numberOfQuestions: widget.numberOfQuestions,
      difficulty: widget.difficulty, // zorluk seviyesini ekledik
    );
    List<Map<String, dynamic>> generatedQuestions = await generator
        .generateQuestions();
    setState(() {
      questions = generatedQuestions;
      _selectedAnswers = List<String?>.filled(questions.length, null);
      isLoading = false;
    });
  }

  void _selectAnswer(String? answer, int index) {
    setState(() {
      _selectedAnswers[index] = answer;
    });
  }

  void _submitQuiz() {
    int correctAnswersCount = 0;
    for (int i = 0; i < questions.length; i++) {
      if (_selectedAnswers[i] == questions[i]['correctAnswer']) {
        correctAnswersCount++;
      }
    }

    List<Map<String, dynamic>> incorrectQuestions = [];
    for (int i = 0; i < questions.length; i++) {
      if (_selectedAnswers[i] != questions[i]['correctAnswer']) {
        incorrectQuestions.add({
          'question': questions[i]['question'],
          'yourAnswer': _selectedAnswers[i],
          'correctAnswer': questions[i]['correctAnswer'],
        });
      }
    }

    _showScoreDialog(correctAnswersCount, incorrectQuestions);
  }

  void _showScoreDialog(int correctAnswersCount,
      List<Map<String, dynamic>> incorrectQuestions) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Quiz Result'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You got $correctAnswersCount out of ${questions
                    .length} correct.'),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QuestionControlScreen(
                              incorrectQuestions: incorrectQuestions,
                            ),
                      ),
                    );
                  },
                  child: Text('See Incorrect Questions'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                        (Route<dynamic> route) => false,
                  );
                },
                child: Text('Home'),
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
          "Multiple Choice Questions",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${question['question']}',
                        style: TextStyle(fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Column(
                        children: question['options'].map<Widget>((option) {
                          return RadioListTile<String>(
                            title: Text(
                                option, style: TextStyle(fontSize: 16.0)),
                            value: option,
                            groupValue: _selectedAnswers[index],
                            onChanged: (value) {
                              _selectAnswer(value, index);
                            },
                            activeColor: Colors.teal,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _submitQuiz,
          child: Text(
            'Submit',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            textStyle: TextStyle(fontSize: 18.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }
}
