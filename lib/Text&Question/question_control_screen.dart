import 'package:flutter/material.dart';
import '../main.dart'; // HomeScreen import

class QuestionControlScreen extends StatelessWidget {
  final List<Map<String, dynamic>> incorrectQuestions;

  QuestionControlScreen({required this.incorrectQuestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incorrect Answers'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: incorrectQuestions.length,
          itemBuilder: (context, index) {
            final question = incorrectQuestions[index];
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
                        '${index + 1}. ${question['question']}',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Your Answer: ${question['yourAnswer']}',
                        style: TextStyle(color: Colors.red, fontSize: 16.0),
                      ),
                      Text(
                        'Correct Answer: ${question['correctAnswer']}',
                        style: TextStyle(color: Colors.green, fontSize: 16.0),
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
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
                  (Route<dynamic> route) => false,
            );
          },
          child: Text('Home'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
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
