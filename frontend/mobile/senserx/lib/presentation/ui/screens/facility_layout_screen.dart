import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senserx/application/facility/facility_layout_service.dart';
import 'package:senserx/domain/models/facility/facility_layout_model.dart';
import 'package:senserx/domain/models/facility/facility_model.dart';
import 'package:senserx/presentation/providers/facility/facility_layout_provider.dart';
import 'package:senserx/presentation/providers/facility/facility_provider.dart';
import 'package:senserx/presentation/theme/app_theme.dart';
import 'package:senserx/presentation/ui/components/common/display/background_scaffold.dart';
import 'package:senserx/presentation/ui/components/common/display/body_wrapper.dart';
import 'package:senserx/presentation/ui/components/common/notifications/senserx_snackbar.dart';
import 'package:senserx/presentation/ui/components/facility/add_facility_layout_form.dart';

import '../../../application/core/facility_layout_icons.dart';

class FacilityLayoutScreen extends StatelessWidget {
  final FacilityLayoutModel layout;
  final FacilityModel facility;

  const FacilityLayoutScreen({Key? key, required this.layout, required this.facility}) : super(key: key);

  /// Builds a list tile for a child layout
  Widget _buildChildLayoutTile(BuildContext context, FacilityLayoutModel childLayout) {
    return ListTile(
      leading: FacilityLayoutIcons.getTypeIcon(childLayout.type),
      title: Text(childLayout.name, style: AppTheme.themeData.textTheme.titleMedium),
      subtitle: Text('Type: ${childLayout.type.toUpperCase()}', style: AppTheme.themeData.textTheme.bodySmall),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FacilityLayoutScreen(layout: childLayout, facility: facility),
          ),
        );
      }
    );
  }

  Widget _trashButton(BuildContext context, String layoutId) {
    return IconButton(
      onPressed: () async {
        bool? deleteConfirmed = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text('Are you sure you want to delete this layout?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );

        if (deleteConfirmed == true) {
          try {
            await FacilityLayoutService().deleteFacilityLayout(facility.uid, layoutId);
            Provider.of<FacilityLayoutProvider>(context, listen: false).removeLayout(layoutId);
            SenseRxSnackbar(
              context: context,
              title: "Success",
              message: "Layout has been deleted",
              isError: false,
            ).show();
            if (layoutId == layout.uid) {
              Navigator.of(context).pop();
            }
          } catch (e) {
            SenseRxSnackbar(
              context: context,
              title: "Error",
              message: "Failed to delete layout",
              isError: true,
            ).show();
          }
        }
      },
      icon: const Icon(Icons.delete_forever, color: Colors.red),
    );
  }

  Widget _addFacilityLayoutButton(BuildContext context, String facilityName, {String? layoutName}) {
    return TextButton(
      onPressed: () async {
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
                    addingTo: layoutName ?? facilityName,
                    facilityId: facility.uid,
                    parentId: layout.uid,
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text("New Layout", style: AppTheme.themeData.textTheme.displayMedium)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final facilityLayoutProvider = Provider.of<FacilityLayoutProvider>(context, listen: true);
    final facilityProvider = Provider.of<FacilityProvider>(context, listen: false);

    FacilityLayoutModel? currentLayout;
    FacilityLayoutModel? findLayout(String uid, List<FacilityLayoutModel> layouts) {
      for (var layout in layouts) {
        if (layout.uid == uid) {
          currentLayout = layout;
          return layout;
        }
        if (layout.children != null && layout.children!.isNotEmpty) {
          var found = findLayout(uid, layout.children!);
          if (found != null) {
            return found;
          }
        }
      }
      return null;
    }

    findLayout(layout.uid, facilityLayoutProvider.layouts);
    currentLayout ??= layout;
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(currentLayout!.name),
      ),
      body: BodyWrapper(
        child: Center(
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white.withOpacity(0.75),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FacilityLayoutIcons.getTypeIcon(currentLayout!.type),
                      const SizedBox(width: 16),
                      Text(
                        currentLayout!.name,
                        style: AppTheme.themeData.textTheme.displayMedium,
                      ),
                      const Spacer(),
                      _trashButton(context, currentLayout!.uid)
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${currentLayout!.type.toUpperCase()}',
                    style: AppTheme.themeData.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentLayout!.description ?? 'No description provided',
                    style: AppTheme.themeData.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Children: ${currentLayout!.children?.length ?? 0}',
                    style: AppTheme.themeData.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentLayout!.children?.length ?? 0,
                      itemBuilder: (context, index) {
                        return _buildChildLayoutTile(
                          context,
                          facilityLayoutProvider.layouts.firstWhere(
                                (element) => element.uid == currentLayout!.children![index].uid,
                            orElse: () => currentLayout!.children![index],
                          ),
                        );
                      },
                    ),
                  ),
                  _addFacilityLayoutButton(context, facilityProvider.facility!.name, layoutName: currentLayout!.name),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}