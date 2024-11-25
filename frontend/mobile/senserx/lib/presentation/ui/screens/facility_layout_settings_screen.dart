import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senserx/application/facility/facility_layout_service.dart';
import 'package:senserx/domain/models/facility/facility_layout_model.dart';
import 'package:senserx/presentation/providers/facility/facility_layout_provider.dart';
import 'package:senserx/presentation/ui/components/common/display/background_scaffold.dart';
import 'package:senserx/presentation/ui/components/common/display/body_wrapper.dart';
import 'package:senserx/presentation/ui/components/common/display/senserx_card.dart';
import 'package:senserx/presentation/ui/components/common/notifications/senserx_snackbar.dart';
import 'package:senserx/presentation/ui/components/facility/edit_facility_layout_form.dart';
class FacilityLayoutSettingsScreen extends StatelessWidget {
  final FacilityLayoutModel layout;
  final VoidCallback onDelete;

  const FacilityLayoutSettingsScreen({
    Key? key,
    required this.layout,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text('Edit Layout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: BodyWrapper(
          paddingLeft: 5,
          paddingRight: 5,
          child: Center(
        child: SenseRxCard(children: [
          EditFacilityLayoutForm(layout: layout)
        ])
      )),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this layout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => _deleteLayout(context),
            ),
          ],
        );
      },
    );
  }

  void _deleteLayout(BuildContext context) async {
    try {
      await FacilityLayoutService().deleteFacilityLayout(layout.facilityId, layout.uid);
      Provider.of<FacilityLayoutProvider>(context, listen: false).removeLayout(layout.uid);
      Navigator.of(context).pop(); // Close the dialog
      onDelete(); // Execute the onDelete callback
      SenseRxSnackbar(
        context: context,
        title: "Success",
        message: "Layout has been deleted",
        isSuccess: true,
      ).show();
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      SenseRxSnackbar(
        context: context,
        title: "Error",
        message: "Failed to delete layout",
        isError: true,
      ).show();
    }
  }
}