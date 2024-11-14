import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senserx/application/facility/facility_layout_service.dart';
import 'package:senserx/application/facility/facility_service.dart';
import 'package:senserx/domain/models/facility/facility_layout_model.dart';
import 'package:senserx/domain/models/facility/facility_model.dart';
import 'package:senserx/presentation/providers/facility/facility_layout_provider.dart';
import 'package:senserx/presentation/providers/facility/facility_provider.dart';
import 'package:senserx/presentation/theme/app_theme.dart';
import 'package:senserx/presentation/ui/components/common/display/background_scaffold.dart';
import 'package:senserx/presentation/ui/components/common/display/body_wrapper.dart';
import 'package:senserx/presentation/ui/components/facility/add_facility_layout_form.dart';
import 'package:senserx/presentation/ui/screens/facility_layout_screen.dart';

class FacilityScreen extends StatelessWidget {
  const FacilityScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final facilityLayoutProvider = Provider.of<FacilityLayoutProvider>(
        context, listen: false);
    final facilityProvider = Provider.of<FacilityProvider>(
        context, listen: false);
    final facilityService = FacilityService();
    final facilityLayoutService = FacilityLayoutService();
    String facilityId = "e3168780-d504-4fbc-9916-f216621644db";

    facilityLayoutProvider.startLoading();
    facilityProvider.startLoading();

    Future.delayed(Duration.zero, () async {
      try {
        FacilityModel facility = await facilityService.getFacilityDetails(
            facilityId);
        List<FacilityLayoutModel> layouts = await facilityLayoutService
            .listFacilityLayoutsByFacilityUid(facilityId);
        facilityProvider.setFacility(facility);
        facilityLayoutProvider.setLayouts(layouts);
      } catch (e) {
        print("Error fetching data: $e");
      }
    });

    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BodyWrapper(
        child: Consumer<FacilityLayoutProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.layouts.isEmpty || facilityProvider.facility == null) {
              return const Center(child: Text("No layout data available."));
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.layouts.length,
                    itemBuilder: (context, index) {
                      final layout = provider.layouts[index];
                      return SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 8,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: _getTypeIcon(layout.type),
                            title: Text(
                              layout.name,
                              style: AppTheme.themeData.textTheme.titleLarge,
                            ),
                            subtitle: Text(
                              "Type: ${layout.type.toUpperCase()} | (${layout
                                  .children?.length ?? 0}) children",
                              style: AppTheme.themeData.textTheme.displaySmall,
                            ),
                            trailing: const Icon(
                                Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FacilityLayoutScreen(layout: layout,
                                          facility: facilityProvider.facility!),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _addFacilityLayoutButton(context, facilityId, facilityProvider.facility!.name)
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _addFacilityLayoutButton(BuildContext context, String facilityId, String facilityName) {
    return TextButton(
      onPressed: () async {
        final result = await showModalBottomSheet(
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
                    addingTo: facilityName,
                    facilityId: facilityId,
                    parentId: null,
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
        children: [
          Text("New Layout", style: AppTheme.themeData.textTheme.displayMedium),
        ],
      ),
    );
  }

  Icon _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'floor':
        return const Icon(Icons.layers, color: Colors.blue);
      case 'room':
        return const Icon(Icons.meeting_room, color: Colors.green);
      case 'section':
        return const Icon(Icons.category, color: Colors.purple);
      case 'wall':
        return const Icon(Icons.photo, color: Colors.brown);
      case 'wing':
        return const Icon(Icons.airplanemode_active, color: Colors.orange);
      case 'unit':
        return const Icon(Icons.house, color: Colors.red);
      default:
        return const Icon(Icons.build, color: Colors.grey);
    }
  }

  Color _getColorByType(String type) {
    switch (type.toLowerCase()) {
      case 'floor':
        return Colors.blue;
      case 'room':
        return Colors.green;
      case 'section':
        return Colors.purple;
      case 'wall':
        return Colors.brown;
      case 'wing':
        return Colors.orange;
      case 'unit':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}