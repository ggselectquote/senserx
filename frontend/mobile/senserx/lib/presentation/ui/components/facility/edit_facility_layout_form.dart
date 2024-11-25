import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';
import '../../../../application/facility/facility_layout_service.dart';
import '../../../../domain/enums/facility_layout.dart';
import '../../../../domain/models/facility/facility_layout_model.dart';
import '../../../providers/facility/facility_layout_provider.dart';
import '../../../theme/app_theme.dart';
import '../common/buttons/primary_button.dart';
import '../common/notifications/senserx_snackbar.dart';

class EditFacilityLayoutForm extends StatefulWidget {
  final FacilityLayoutModel layout;

  const EditFacilityLayoutForm({super.key, required this.layout});

  @override
  _EditFacilityLayoutFormState createState() => _EditFacilityLayoutFormState();
}

class _EditFacilityLayoutFormState extends State<EditFacilityLayoutForm> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late String _selectedType = widget.layout.type;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.layout.name;
  }

  Future<void> _submitForm() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      try {
        var updatedLayout = await FacilityLayoutService().updateFacilityLayout(
            dotenv.env["FACILITY_ID"]!,
            widget.layout.uid,
            FacilityLayoutModel(
            uid: widget.layout.uid,
            facilityId: dotenv.env["FACILITY_ID"]!,
            name: _nameController.text,
            type: _selectedType)
        );
        Provider.of<FacilityLayoutProvider>(context, listen: false)
            .updateLayout(updatedLayout);
        SenseRxSnackbar(
            context: context,
            title: "Success",
            message: "Layout updated successfully",
            isSuccess: true
        ).show();
        Navigator.pop(context);
      } catch (e) {
        SenseRxSnackbar(
          context: context,
          title: "Error",
          message: "Failed to update layout: $e",
          isError: true,
        ).show();
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? formTextStyle =  AppTheme.themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Layout Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ...FacilityLayout.values
                .map((type) => RadioListTile<String>(
              title: Text(type.name.toUpperCase(), style: formTextStyle),
              value: type.name,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ))
                .toList(),
            const SizedBox(height: 24),
            PrimaryButton(
              text: "Update Layout",
              onPressed: _submitForm,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}