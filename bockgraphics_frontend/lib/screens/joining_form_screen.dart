import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/file_downloader.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../auth/token_store.dart';
class JoiningFormScreen extends StatefulWidget {
  const JoiningFormScreen({Key? key}) : super(key: key);

  @override
  State<JoiningFormScreen> createState() => _JoiningFormScreenState();
}

class _JoiningFormScreenState extends State<JoiningFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController programController = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  String company = '';
  bool isSubmitting = false;

  void clearForm() {
    setState(() {
      nameController.clear();
      programController.clear();
      issueDateController.clear();
      startDateController.clear();
      endDateController.clear();
    });
  }

  Future<void> _pickDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      locale: const Locale('en', 'GB'),
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }
  Future<void> _generateJoiningDocx() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);
  try {
    final url = Uri.parse(
      "${dotenv.env['API_BASE_URL']}/generate-joining",
    );
    
    final token = await TokenStore.read();
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json","Authorization": "Bearer $token",},
      body: jsonEncode({
        "name": nameController.text,
        "program": programController.text,
        "issueDate": issueDateController.text,
        "startDate": startDateController.text,
        "endDate": endDateController.text,
        "field": company, // Automotive / Food / Bock
      }),
    );

    if (response.statusCode == 200) {
      final downloader = getFileDownloader();
      await downloader.saveFile(
        response.bodyBytes,
        "${company}_Joining_Letter.docx",
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Joining letter generated successfully"),
        ),
      );
    } else {
      throw Exception("Server error ${response.statusCode}");
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
  finally {
    if (mounted) {
      setState(() => isSubmitting = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
     final args = ModalRoute.of(context)?.settings.arguments as Map?;
   company = args?['company'] ?? 'Unknown';
    return Scaffold(
      appBar: AppBar(title: Text('Bock $company Joining Letter')),
      body: Center(
        child: SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraints) {
            double width = constraints.maxWidth < 600 ? constraints.maxWidth * 0.95 : 450;
            return Container(
              width: width,
              padding: const EdgeInsets.all(8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Name'),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(hintText: 'Enter name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Program name'),
                    TextFormField(
                      controller: programController,
                      decoration: const InputDecoration(hintText: 'Enter program'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter program name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Issue date'),
                    TextFormField(
                      controller: issueDateController,
                      decoration: const InputDecoration(hintText: 'DD/MM/YYYY'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select issue date';
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: () => _pickDate(context, issueDateController),
                    ),
                    const SizedBox(height: 12),
                    const Text('Start date'),
                    TextFormField(
                      controller: startDateController,
                      decoration: const InputDecoration(hintText: 'DD/MM/YYYY'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select start date';
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: () => _pickDate(context, startDateController),
                    ),
                    const SizedBox(height: 12),
                    const Text('End date'),
                    TextFormField(
                      controller: endDateController,
                      decoration: const InputDecoration(hintText: 'DD/MM/YYYY'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select end date';
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: () => _pickDate(context, endDateController),
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
                            onPressed: () {
  if (_formKey.currentState?.validate() ?? true) {
    _generateJoiningDocx();
  }
},
                            child: isSubmitting
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text('SAVE'),
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
                            child: const Text('CLEAR'),
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
}
