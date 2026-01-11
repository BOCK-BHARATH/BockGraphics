import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/file_downloader.dart';

class CompletionLetterFormScreen extends StatefulWidget {
  const CompletionLetterFormScreen({Key? key}) : super(key: key);

  @override
  State<CompletionLetterFormScreen> createState() =>
      _CompletionLetterFormScreenState();
}

class _CompletionLetterFormScreenState
    extends State<CompletionLetterFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final workController = TextEditingController();
  final proficiencyController = TextEditingController();
  final issueDateController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  double? months;
  String company = '';
  bool isSubmitting = false;

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      locale: const Locale('en', 'GB'),
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  String formatMonths(double? value) {
    if (value == null) return '';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  void clearForm() {
    setState(() {
      nameController.clear();
      workController.clear();
      proficiencyController.clear();
      issueDateController.clear();
      startDateController.clear();
      endDateController.clear();
      months = null;
    });
  }

  Future<void> generateLetter() async {
    if (!_formKey.currentState!.validate() || isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      final url = Uri.parse(
        "${dotenv.env['API_BASE_URL']}/generate-completion-letter",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "issueDate": issueDateController.text,
          "work": workController.text,
          "proficiency": proficiencyController.text,
          "months": formatMonths(months),
          "startDate": startDateController.text,
          "endDate": endDateController.text,
          "field": company,
        }),
      );

      if (response.statusCode == 200) {
        await getFileDownloader().saveFile(
          response.bodyBytes,
          "${company}_Completion_Letter.docx",
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Completion letter generated")),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    company = args?['company'] ?? 'Bock';

    return Scaffold(
      appBar: AppBar(title: Text('Bock $company Completion Letter')),
      body: Center(
        child: SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraints) {
            double width =
                constraints.maxWidth < 600 ? constraints.maxWidth * 0.95 : 450;

            return Container(
              width: width,
              padding: const EdgeInsets.all(8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field("Name", nameController, "Enter full name"),
                    _field("Work / Domain", workController,
                        "Enter work domain"),
                    _field("Proficiency", proficiencyController,
                        "Enter proficiency level"),

                    _dateField("Issue Date", issueDateController),
                    _dateField("Start Date", startDateController),
                    _dateField("End Date", endDateController),

                    const Text("Number of Months"),
                    TextFormField(
                      decoration:
                          const InputDecoration(hintText: "e.g. 3 or 3.5"),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final val = double.tryParse(v ?? '');
                        if (val == null || val <= 0) {
                          return 'Enter valid months';
                        }
                        return null;
                      },
                      onChanged: (v) => months = double.tryParse(v),
                    ),

                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[400],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: generateLetter,
                            child: isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text("SAVE"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[200],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: clearForm,
                            child: const Text("CLEAR"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _dateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(hintText: "DD/MM/YYYY"),
          readOnly: true,
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
          onTap: () => _pickDate(context, controller),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
