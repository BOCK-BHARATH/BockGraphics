import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/file_downloader.dart';
import '../auth/token_store.dart';

class CompletionCertificateForm extends StatefulWidget {
  const CompletionCertificateForm({Key? key}) : super(key: key);

  @override
  State<CompletionCertificateForm> createState() =>
      _CompletionCertificateFormState();
}

class _CompletionCertificateFormState
    extends State<CompletionCertificateForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final titleController = TextEditingController();
  final hoursController = TextEditingController();
  final specializationController = TextEditingController();
  final coursesController = TextEditingController();
  final monthsController = TextEditingController();
  final descriptionController = TextEditingController();

  String company = '';
  bool isSubmitting = false;

  void clearForm() {
    setState(() {
      nameController.clear();
      titleController.clear();
      hoursController.clear();
      specializationController.clear();
      coursesController.clear();
      monthsController.clear();
      descriptionController.clear();
    });
  }

  Future<void> generateCertificate() async {
    if (!_formKey.currentState!.validate() || isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      final url = Uri.parse(
        "${dotenv.env['API_BASE_URL']}/generate-completion-certificate",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json","Authorization": "Bearer ${await getTokenStore().read()}",},
        body: jsonEncode({
          "name": nameController.text,
          "title": titleController.text,
          "hours": hoursController.text,
          "specialization": specializationController.text,
          "courses": coursesController.text,
          "months": monthsController.text,
          "description": descriptionController.text,
          "field": company,
        }),
      );

      if (response.statusCode == 200) {
        await getFileDownloader().saveFile(
          response.bodyBytes,
          "${company}_Completion_Certificate.docx",
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Certificate generated successfully")),
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
      appBar: AppBar(title: Text('Bock $company Completion Certificate')),
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
                    _field("Title / Program", titleController,
                        "Enter program title"),
                    _field("Hours", hoursController, "Enter total hours"),
                    _field("Specialization", specializationController,
                        "Enter specialization"),
                    _field("Courses", coursesController,
                        "Enter courses covered"),
                    _field("Months", monthsController,
                        "Enter duration in months"),
                    _field(
                      "Description",
                      descriptionController,
                      "Enter certificate description",
                      maxLines: 6,
                      maxLength: 13000,
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
                            onPressed: generateCertificate,
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
    String hint, {
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(hintText: hint),
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
