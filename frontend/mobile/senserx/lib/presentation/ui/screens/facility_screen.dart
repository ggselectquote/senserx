import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:senserx/application/facility/facility_layout_service.dart';
import 'package:senserx/application/facility/facility_service.dart';
import 'package:senserx/domain/models/facility/facility_layout_model.dart';
import 'package:senserx/domain/models/facility/facility_model.dart';
import 'package:senserx/presentation/providers/facility/facility_layout_provider.dart';
import 'package:senserx/presentation/providers/facility/facility_provider.dart';
import 'package:senserx/presentation/theme/app_theme.dart';
import 'package:senserx/presentation/ui/components/common/buttons/primary_button.dart';
import 'package:senserx/presentation/ui/components/common/display/background_scaffold.dart';
import 'package:senserx/presentation/ui/components/common/display/body_wrapper.dart';
import 'package:senserx/presentation/ui/components/common/display/senserx_card.dart';
import 'package:senserx/presentation/ui/components/facility/add_facility_layout_form.dart';
import 'package:senserx/presentation/ui/screens/facility_layout_screen.dart';

import '../components/facility/new_facility_layout_button.dart';
import '../components/facility/pair_shelf_button.dart';
import '../components/wifi/wifi_floating_action_button.dart';

class FacilityScreen extends StatelessWidget {
  const FacilityScreen({Key? key, required this.title, this.facilityId}) : super(key: key);

  final String? facilityId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final facilityLayoutProvider =
        Provider.of<FacilityLayoutProvider>(context, listen: false);
    final facilityProvider =
        Provider.of<FacilityProvider>(context, listen: false);
    final facilityService = FacilityService();
    final facilityLayoutService = FacilityLayoutService();
    String _facilityId = facilityId ?? dotenv.env['FACILITY_ID'] ?? "";

    Future.delayed(Duration.zero, () async {
      try {
        FacilityModel facility =
            await facilityService.getFacilityDetails(_facilityId);
        List<FacilityLayoutModel> layouts = await facilityLayoutService
            .listFacilityLayoutsByFacilityUid(_facilityId);
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
        paddingLeft: 5,
        paddingRight: 5,
        child: Consumer<FacilityLayoutProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                // Facility Card
                SenseRxCard(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business,
                            color: AppTheme.themeData.primaryColor),
                        const SizedBox(width: 16),
                        Text(
                          facilityProvider.facility!.name,
                          style: AppTheme.themeData.textTheme.displayMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contact: ${facilityProvider.facility!.contact ?? "N/A"}',
                      style: AppTheme.themeData.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      facilityProvider.facility!.address ??
                          'No address provided',
                      style: AppTheme.themeData.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Layouts: ${facilityLayoutProvider.layouts.length}',
                      style: AppTheme.themeData.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: OverflowBar(
                        spacing: 8,
                        overflowAlignment: OverflowBarAlignment.end,
                        children: <Widget>[
                          NewFacilityLayoutButton(
                              facility: facilityProvider.facility!,
                              layout: null
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: facilityLayoutProvider.layouts.length,
                    itemBuilder: (context, index) {
                      final layout = facilityLayoutProvider.layouts[index];
                      return SenseRxCard(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          children: [
                        ListTile(
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          leading:
                              FacilityService.getFacilityLayoutType(layout.type)
                                  .icon,
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              layout.name,
                              style: AppTheme.themeData.textTheme.bodyLarge,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "(${layout.children?.length ?? 0}) layouts | (${layout.shelves?.length  ?? 0}) shelves",
                                style:
                                    AppTheme.themeData.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 24),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FacilityLayoutScreen(
                                  layout: layout,
                                  facility: facilityProvider.facility!,
                                ),
                              ),
                            );
                          },
                        )
                      ]);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
