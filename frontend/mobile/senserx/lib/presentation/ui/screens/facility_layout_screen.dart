import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senserx/application/facility/facility_layout_service.dart';
import 'package:senserx/domain/models/facility/facility_layout_model.dart';
import 'package:senserx/domain/models/facility/facility_model.dart';
import 'package:senserx/presentation/providers/facility/facility_layout_provider.dart';
import 'package:senserx/presentation/providers/facility/facility_provider.dart';
import 'package:senserx/presentation/theme/app_theme.dart';
import 'package:senserx/presentation/ui/components/common/buttons/primary_button.dart';
import 'package:senserx/presentation/ui/components/common/display/background_scaffold.dart';
import 'package:senserx/presentation/ui/components/common/display/body_wrapper.dart';
import 'package:senserx/presentation/ui/components/common/display/senserx_card.dart';
import 'package:senserx/presentation/ui/components/common/notifications/senserx_snackbar.dart';
import 'package:senserx/presentation/ui/components/facility/add_facility_layout_form.dart';
import 'package:senserx/presentation/ui/components/facility/new_facility_layout_button.dart';
import 'package:senserx/presentation/ui/components/facility/pair_shelf_button.dart';

import '../../../application/core/facility_layout_icons.dart';
import '../../providers/application/global_context_provider.dart';
import '../components/wifi/wifi_floating_action_button.dart';

class FacilityLayoutScreen extends StatefulWidget {
  final FacilityLayoutModel layout;
  final FacilityModel facility;

  const FacilityLayoutScreen({
    Key? key,
    required this.layout,
    required this.facility,
  }) : super(key: key);

  @override
  _FacilityLayoutScreenState createState() => _FacilityLayoutScreenState();
}

class _FacilityLayoutScreenState extends State<FacilityLayoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FacilityLayoutModel currentLayout;
  late FacilityProvider _facilityProvider;
  late FacilityLayoutProvider _facilityLayoutProvider;
  var totalLayouts = 0;
  var totalShelves = 0;
  FacilityLayoutService _facilityLayoutService = FacilityLayoutService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _updateCurrentLayout();
    _facilityLayoutProvider =
        Provider.of<FacilityLayoutProvider>(context, listen: false);
    _facilityProvider = Provider.of<FacilityProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GlobalContextProvider>(context, listen: false)
          .updateCurrentView(FacilityLayoutScreen, id: widget.layout.uid);
    });
  }

  @override
  void didUpdateWidget(FacilityLayoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.layout != oldWidget.layout) {
      _updateCurrentLayout();
    }
  }

  void _updateCurrentLayout() {
    final facilityLayoutProvider =
        Provider.of<FacilityLayoutProvider>(context, listen: false);
    currentLayout =
        _findLayout(widget.layout.uid, facilityLayoutProvider.layouts) ??
            widget.layout;
    var response = _facilityLayoutService.countShelvesAndLayouts([currentLayout]);
    totalLayouts = response[0]?['layouts'] ?? 0;
    totalShelves = response[0]?['shelves'] ?? 0;
  }

  FacilityLayoutModel? _findLayout(
      String uid, List<FacilityLayoutModel> layouts) {
    for (var layout in layouts) {
      if (layout.uid == uid) {
        return layout;
      }
      if (layout.children != null && layout.children!.isNotEmpty) {
        var found = _findLayout(uid, layout.children!);
        if (found != null) {
          return found;
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Builds a list tile for a child layout
  Widget _buildChildLayoutTile(
      BuildContext context, FacilityLayoutModel childLayout) {
    return ListTile(
        leading: FacilityLayoutIcons.getTypeIcon(childLayout.type),
        title: Text(childLayout.name,
            style: AppTheme.themeData.textTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "(${childLayout.subLayouts?.length ?? 0}) layouts | (${childLayout.shelves?.length ?? 0}) shelves",
              style: AppTheme.themeData.textTheme.bodyMedium,
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
                builder: (context) => FacilityLayoutScreen(
                    layout: childLayout, facility: widget.facility)),
          )
              .then((_) {
            Provider.of<GlobalContextProvider>(context, listen: false)
                .updateCurrentView(null);
          });
        });
  }

  Widget _trashButton(BuildContext context, String layoutId) {
    return IconButton(
      onPressed: () async {
        bool? deleteConfirmed = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content:
                  const Text('Are you sure you want to delete this layout?'),
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
            await FacilityLayoutService()
                .deleteFacilityLayout(widget.facility.uid, layoutId);
            Provider.of<FacilityLayoutProvider>(context, listen: false)
                .removeLayout(layoutId);
            SenseRxSnackbar(
              context: context,
              title: "Success",
              message: "Layout has been deleted",
              isError: false,
              isSuccess: true,
            ).show();
            if (layoutId == widget.layout.uid) {
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
      icon: const Icon(Icons.delete_forever, color: Colors.white, size: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(currentLayout!.name),
        actions: [_trashButton(context, currentLayout!.uid)],
      ),
      body: BodyWrapper(
        paddingRight: 5,
        paddingLeft: 5,
        child: Center(
          child: SenseRxCard(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional.center,
                child: OverflowBar(
                  spacing: 8,
                  overflowAlignment: OverflowBarAlignment.end,
                  children: <Widget>[
                    NewFacilityLayoutButton(
                        facility: widget.facility, layout: widget.layout),
                    PairShelfButton(
                      facilityId: _facilityProvider.facility!.uid.toString(),
                      facilityLayoutId: widget.layout.uid.toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                              Text(
                                  '(${currentLayout?.children?.length ?? 0})',
                                  style: AppTheme.themeData.textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700, fontSize: 20)),
                              const SizedBox(width: 8),
                              Text('Layouts',
                                  style:
                                      AppTheme.themeData.textTheme.bodyMedium?.copyWith(fontSize: 20)),
                            ])),
                        Tab(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                              Text('(${currentLayout?.shelves?.length ?? 0})',
                                  style: AppTheme.themeData.textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700, fontSize: 20)),
                              const SizedBox(width: 8),
                              Text('Shelves',
                                  style:
                                      AppTheme.themeData.textTheme.bodyMedium?.copyWith(fontSize: 20))
                            ])),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          ListView.builder(
                            itemCount: currentLayout!.children?.length ?? 0,
                            itemBuilder: (context, index) {
                              return _buildChildLayoutTile(
                                context,
                                _facilityLayoutProvider.layouts.firstWhere(
                                  (element) =>
                                      element.uid ==
                                      currentLayout!.children![index].uid,
                                  orElse: () => currentLayout!.children![index],
                                ),
                              );
                            },
                          ),
                          // Add your Shelves tab content here
                          Container(), // Placeholder for Shelves tab
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
