import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl package for formatting
import 'package:docx_template/docx_template.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/file_downloader.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OfferFormScreen extends StatefulWidget {
  const OfferFormScreen({Key? key}) : super(key: key);

  @override
  State<OfferFormScreen> createState() => _OfferFormScreenState();
}

class _OfferFormScreenState extends State<OfferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController programController = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  double? months;
  String? internshipType;
  String company = '';
  bool isSubmitting = false;

  void clearForm() {
    setState(() {
      nameController.clear();
      programController.clear();
      issueDateController.clear();
      startDateController.clear();
      endDateController.clear();
      months = null;
      internshipType = null;
    });
  }

  bool _validateMode() {
    if (internshipType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select internship mode')),
      );
      return false;
    }
    return true;
  }

  Future<void> _generateDocx() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);
    try {
      final url = Uri.parse("${dotenv.env['API_BASE_URL']}/generate-offer");
      String formatMonths(double? months) {
        if (months == null) return '';
        if (months % 1 == 0) {
          return months.toInt().toString(); // whole number
        }
        return months.toString(); // decimal
      }

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "program": programController.text,
          "issueDate": issueDateController.text,
          "startDate": startDateController.text,
          "endDate": endDateController.text,
          "months": formatMonths(months),
          "mode": internshipType ?? "",
          "field": company,
        }),
      );

      if (response.statusCode == 200) {
        final downloader = getFileDownloader();
        await downloader.saveFile(
          response.bodyBytes,
          "${company}_Offer_Letter.docx",
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Offer letter generated successfully")),
        );
      } else {
        throw Exception("Server error ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      locale: const Locale('en', 'GB'), // 🔥 IMPORTANT
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    company = args?['company'] ?? 'Unknown';
    return Scaffold(
      appBar: AppBar(title: Text('Bock $company Offer Letter')),
      body: Center(
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth < 600
                  ? constraints.maxWidth * 0.95
                  : 450;
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
                        decoration: const InputDecoration(
                          hintText: 'Enter name',
                        ),
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
                        decoration: const InputDecoration(
                          hintText: 'Enter program',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter program name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text('Mode'),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: internshipType == 'ONLINE'
                                    ? Colors.green[700]
                                    : Colors.green[400],
                                foregroundColor: internshipType == 'ONLINE'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  internshipType = 'ONLINE';
                                });
                              },
                              child: const Text('ONLINE'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: internshipType == 'OFFLINE'
                                    ? Colors.brown[700]
                                    : Colors.brown[300],
                                foregroundColor: internshipType == 'OFFLINE'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  internshipType = 'OFFLINE';
                                });
                              },
                              child: const Text('OFFLINE'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: internshipType == 'HYBRID'
                                    ? Colors.blueGrey[700]
                                    : Colors.blueGrey[400],
                                foregroundColor: internshipType == 'HYBRID'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  internshipType = 'HYBRID';
                                });
                              },
                              child: const Text('HYBRID'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Issue date'),
                      TextFormField(
                        controller: issueDateController,
                        decoration: const InputDecoration(
                          hintText: 'DD/MM/YYYY',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select issue date';
                          }
                          return null;
                        },
                        readOnly: true,
                        onTap: () => _pickDate(context, issueDateController),
                      ),
                      TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Number of months of internship',
                          hintText: 'e.g. 3.5',
                        ),
                        onChanged: (value) {
                          setState(() {
                            months = double.tryParse(value);
                          });
                        },
                        validator: (value) {
                          final v = double.tryParse(value ?? '');
                          if (v == null || v <= 0) {
                            return 'Enter a valid number of months';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text('Start date'),
                      TextFormField(
                        controller: startDateController,
                        decoration: const InputDecoration(
                          hintText: 'DD/MM/YYYY',
                        ),
                        readOnly: true,
                        onTap: () => _pickDate(context, startDateController),
                      ),
                      const SizedBox(height: 12),
                      const Text('End date'),
                      TextFormField(
                        controller: endDateController,
                        decoration: const InputDecoration(
                          hintText: 'DD/MM/YYYY',
                        ),
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
                                final isValidForm =
                                    _formKey.currentState?.validate() ?? false;
                                final isValidMode = _validateMode();

                                if (isValidForm && isValidMode) {
                                  _generateDocx();
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
            },
          ),
        ),
      ),
    );
  }
}
