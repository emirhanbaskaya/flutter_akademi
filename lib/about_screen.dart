import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About EduQuest',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to EduQuest, the premier solution designed for viewing and interacting with PDF documents. Our application harnesses the latest technology to provide a seamless and intuitive experience, allowing users to not only view PDFs but also generate questions directly from the content.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Key Features',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Advanced PDF Viewer: Effortlessly view and navigate through PDF documents with our user-friendly interface.\n'
                  '• Question Generation: Automatically generate questions from your PDFs to facilitate learning and assessment.\n'
                  '• Interactive Annotations: Add notes, highlights, and other annotations to your PDF documents for a personalized experience.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Our Mission',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Our mission is to revolutionize the way users interact with PDF documents, making it easier and more efficient to extract valuable information and facilitate learning. We are committed to continuous innovation and excellence, ensuring our users have the best tools at their fingertips.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Contact Us',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'For any questions or feedback, feel free to reach out to us:\n'
                  'Email: emirhanbaskayaa@gmail.com\n'
                  'Phone: +90 535 493 8478',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
