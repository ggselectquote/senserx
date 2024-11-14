import'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senserx/application/facility/facility_layout_service.dart';
import 'package:senserx/domain/models/facility/facility_layout_model.dart';
import 'package:senserx/presentation/providers/facility/facility_layout_provider.dart';
import 'package:senserx/presentation/ui/components/common/buttons/cancel_button.dart';
import 'package:senserx/presentation/ui/components/common/buttons/primary_button.dart';
import 'package:senserx/presentation/ui/components/common/notifications/senserx_snackbar.dart';

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

  final List<String> _types = [
    'floor',
    'room',
    'section',
    'wall',
    'wing',
    'unit'
  ];

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
  }

  Future<void> _submitForm() async {
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
        SenseRxSnackbar(
          context: context,
          title: "Success",
          message: "Layout added successfully",
          isError: false,
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Text(
                "Add New Layout to ${widget.addingTo}",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
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
                onEditingComplete: () {
                  _formKey.currentState?.validate();
                },
              ),
              const SizedBox(height: 16),
              ..._types
                  .map((type) => RadioListTile<String>(
                        title: Text(type.toUpperCase()),
                        value: type,
                        groupValue: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ))
                  .toList(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: "Add Layout",
                onPressed: _submitForm,
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
    _nameFocus.removeListener(() {}); // Remove the listener before disposing
    _nameFocus.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
