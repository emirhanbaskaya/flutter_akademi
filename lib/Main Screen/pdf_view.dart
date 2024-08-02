import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../Text&Question/question_setup.dart';

class PDFViewScreen extends StatefulWidget {
  final String pdfPath;

  PDFViewScreen({required this.pdfPath});

  @override
  _PDFViewScreenState createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  late PDFViewController _pdfViewController;
  int _pages = 0;
  int _currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.pdfPath,
            autoSpacing: true,
            enableSwipe: true, // Sayfa geçişleri için swipe etkin
            pageSnap: true,
            swipeHorizontal: false,
            nightMode: false,
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onRender: (_pages) {
              setState(() {
                this._pages = _pages!;
                isReady = true;
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfViewController = pdfViewController;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
          ),
          if (errorMessage.isEmpty && isReady)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black87, // Kontrastı artırmak için rengi değiştirildi
                height: 70, // Üst barın yüksekliği
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.pdfPath.split('/').last,
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final selectedPage = await showDialog<int>(
                          context: context,
                          builder: (context) {
                            return PageSelectorDialog(pages: _pages);
                          },
                        );
                        if (selectedPage != null) {
                          setState(() {
                            _currentPage = selectedPage;
                          });
                          await _pdfViewController.setPage(selectedPage);
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            '${_currentPage + 1}/$_pages',
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (errorMessage.isEmpty && isReady)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black87, // Kontrastı artırmak için rengi değiştirildi
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_upward, color: Colors.white),
                      onPressed: () {
                        if (_currentPage > 0) {
                          _pdfViewController.setPage(_currentPage - 1);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_downward, color: Colors.white),
                      onPressed: () {
                        if (_currentPage < _pages - 1) {
                          _pdfViewController.setPage(_currentPage + 1);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.question_answer, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestionSetupScreen(pdfPath: widget.pdfPath),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          if (!isReady)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (errorMessage.isNotEmpty)
            Center(
              child: Text(errorMessage, style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}

class PageSelectorDialog extends StatelessWidget {
  final int pages;

  PageSelectorDialog({required this.pages});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Page'),
            SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pages,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${index + 1}'), // Sayfa numaralarını sadece numara olarak göster
                    onTap: () {
                      Navigator.of(context).pop(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
