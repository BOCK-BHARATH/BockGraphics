import 'package:flutter/material.dart';

class CompanySelectionScreen extends StatelessWidget {
  const CompanySelectionScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> companies = const [
    {'label': 'Automotive', 'color': Color(0xFFFFD6D6)},
    {'label': 'Foods', 'color': Color(0xFFD6FFD6)},
    {'label': 'Space', 'color': Color(0xFFD6DBFF)},
    {'label': 'Ai', 'color': Color(0xFFD6B689)},
    {'label': 'Health', 'color': Color(0xFFFFF6D6)},
    {'label': 'Chain', 'color': Color(0xFFD6D6FF)},
    {'label': 'Institutes', 'color': Color(0xFFD6FFC4)},
    {'label': 'Force', 'color': Color(0xFFFFD68B)},
    {'label': 'Parent', 'color': Color(0xFF3F3F3F)},
  ];

  @override
  Widget build(BuildContext context) {
    
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final String letterType = args?['letterType'] ?? 'offer';
  debugPrint("LetterType received: $letterType");

    String getRoute() {
      switch (letterType) {
        case 'offer':
          return '/offer_form';
        case 'joining':
          return '/joining_form';
        case 'completion_letter':
          return '/completion_letter_form';
        case 'completion_certificate':
          return '/completion_certificate_form';
        default:
          return '/offer_form';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitle(letterType),
        ),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width =
                constraints.maxWidth < 600 ? constraints.maxWidth * 0.95 : 450;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: companies.map((company) {
                final isParent = company['label'] == 'Parent';

                return Container(
                  width: width,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: company['color'],
                      foregroundColor:
                          isParent ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        getRoute(),
                        arguments: {
                          'company': company['label'],
                        },
                      );
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        company['label'],
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isParent
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  String _getTitle(String letterType) {
    switch (letterType) {
      case 'offer':
        return 'Select Company – Offer Letter';
      case 'joining':
        return 'Select Company – Joining Letter';
      case 'completion_letter':
        return 'Select Company – Completion Letter';
      case 'completion_certificate':
        return 'Select Company – Completion Certificate';
      default:
        return 'Select Company';
    }
  }
}
