import 'package:flutter/material.dart';
import 'package:senserx/domain/models/facility/facility_model.dart';
import 'package:senserx/domain/models/facility/facility_layout_model.dart';
import 'package:senserx/presentation/ui/components/facility/add_facility_layout_form.dart';

class NewFacilityLayoutButton extends StatelessWidget {
  final FacilityModel facility;
  final FacilityLayoutModel? layout;
  final String? layoutName;

  const NewFacilityLayoutButton({
    super.key,
    required this.facility,
    this.layout,
    this.layoutName,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await _showAddFacilityLayoutForm(context);
      },
      icon: const Icon(Icons.add),
      label: const Text('New Layout'),
    );
  }

  Future<void> _showAddFacilityLayoutForm(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: AddFacilityLayoutForm(
                addingTo: layoutName ?? facility.name,
                facilityId: facility.uid,
                parentId: layout?.uid,
              ),
            ),
          ),
        );
      },
    );
  }
}