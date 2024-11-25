import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senserx/application/core/definitions.dart';
import 'package:senserx/application/facility/facility_layout_service.dart';
import 'package:senserx/domain/enums/facility_layout.dart';
import 'package:senserx/domain/models/facility/facility_layout_model.dart';
import 'package:senserx/presentation/providers/facility/facility_layout_provider.dart';
import 'package:senserx/presentation/ui/components/common/buttons/cancel_button.dart';
import 'package:senserx/presentation/ui/components/common/buttons/primary_button.dart';
import 'package:senserx/presentation/ui/components/common/notifications/senserx_snackbar.dart';

import '../../../../application/core/shared_preferences.dart';
import '../../../theme/app_theme.dart';

class AddFacilityLayoutForm extends StatefulWidget {
  final String? parentId;
  final String facilityId;
  final String addingTo;

  const AddFacilityLayoutForm({
    super.key,
    required this.facilityId,
    required this.addingTo,
    this.parentId,
  });

  @override
  _AddFacilityLayoutFormState createState() => _AddFacilityLayoutFormState();
}

class _AddFacilityLayoutFormState extends State<AddFacilityLayoutForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedType = 'floor';
  final FocusNode _nameFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late SharedPreferencesService _sharedPrefs;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) {
        Future.delayed(Duration.zero, () {
          _formKey.currentState?.validate();
        });
      }
    });
    _initSharedPrefs();
  }

  Future<void> _initSharedPrefs() async {
    _sharedPrefs = await SharedPreferencesService.getInstance();
  }

  Future<void> _submitForm() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      FacilityLayoutModel layout = FacilityLayoutModel(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        facilityId: widget.facilityId,
        parentId: widget.parentId ?? "",
        name: _nameController.text,
        type: _selectedType,
        children: [],
        description: _descriptionController.text,
      );

      try {
        var createdLayout = await FacilityLayoutService()
            .createFacilityLayout(widget.facilityId, layout);
        Provider.of<FacilityLayoutProvider>(context, listen: false)
            .addLayout(createdLayout);
        await _sharedPrefs.setBool(Definitions.SHOULD_FETCH, true);
        SenseRxSnackbar(
            context: context,
            title: "Success",
            message: "${_nameController.text} added successfully",
            isSuccess: true
        ).show();
        Navigator.pop(context, layout);
      } catch (e, s) {
        print(e);
        print(s);
        // Show error message
        SenseRxSnackbar(
          context: context,
          title: "Error",
          message: "Failed to add layout: $e",
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
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 40, color: AppTheme.themeData.primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    'New Layout',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.themeData.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 16),
              TextFormField(
                style: formTextStyle,
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: 'Layout Name',
                  labelStyle: formTextStyle,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onEditingComplete: () {
                  _nameFocus.unfocus();
                  _formKey.currentState?.validate();
                },
              ),
              const SizedBox(height: 16),
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
                text: "Add Layout",
                onPressed: _submitForm,
                isLoading: isLoading,
              ),
              const SizedBox(height: 16),
              const CancelButton()
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameFocus.removeListener(() {});
    _nameFocus.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
