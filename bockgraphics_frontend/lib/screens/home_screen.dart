import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> options = const [
    {'label': 'Internship Offer Letter', 'letterType': 'offer'},
    {'label': 'Internship Joining Letter', 'letterType': 'joining'},
    {'label': 'Internship Completion Certificate', 'letterType': 'completion_certificate'},
    {'label': 'Internship Completion Letter', 'letterType': 'completion_letter'},
    {'label': 'ID Card', 'letterType': 'idcard'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Back Graphics')),
      body: Center(
        child: LayoutBuilder(builder: (_, constraints) {
          double width = constraints.maxWidth < 600 ? constraints.maxWidth * 0.95 : 450;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: options.map((opt) => Container(
              width: width,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                ),
                onPressed: () {
                  // Pass letterType as argument when navigating
                  Navigator.pushNamed(
                    context,
                    '/companies',
                    arguments: {'letterType': opt['letterType']},
                  );
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(opt['label']!, style: const TextStyle(fontSize: 17)),
                ),
              ),
            )).toList(),
          );
        }),
      ),
    );
  }
}
