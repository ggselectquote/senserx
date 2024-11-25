import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senserx/application/facility/facility_layout_service.dart';
import 'package:senserx/application/products/product_service.dart';
import 'package:senserx/domain/models/facility/facility_layout_model.dart';
import 'package:senserx/domain/models/facility/facility_model.dart';
import 'package:senserx/domain/models/facility/sense_shelf_model.dart';
import 'package:senserx/presentation/providers/facility/facility_layout_provider.dart';
import 'package:senserx/presentation/providers/facility/facility_provider.dart';
import 'package:senserx/presentation/theme/app_theme.dart';
import 'package:senserx/presentation/ui/components/common/display/background_scaffold.dart';
import 'package:senserx/presentation/ui/components/common/display/body_wrapper.dart';
import 'package:senserx/presentation/ui/components/common/display/senserx_card.dart';
import 'package:senserx/presentation/ui/components/common/notifications/senserx_snackbar.dart';
import 'package:senserx/presentation/ui/components/facility/new_facility_layout_button.dart';
import 'package:senserx/presentation/ui/components/facility/pair_shelf_button.dart';
import 'package:intl/intl.dart';
import 'package:senserx/presentation/ui/components/facility/shelf_provisioning_form.dart';
import 'package:senserx/presentation/ui/screens/facility_screen.dart';

import '../../../application/core/facility_layout_icons.dart';
import '../../../domain/models/products/product_details.dart';
import '../../providers/application/global_context_provider.dart';
import 'facility_layout_settings_screen.dart';

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
  final ProductService _productService = ProductService();
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
    var response =
        _facilityLayoutService.countShelvesAndLayouts([currentLayout]);
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

  Widget _buildShelfLayoutTile(BuildContext context, SenseShelfModel shelf) {
    return ListTile(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: BodyWrapper(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                  child: ShelfProvisioningForm(
                      shelf: shelf, initialLayoutId: shelf.layoutId),
                ),
              ),
            );
          },
        );
      },
      leading: _buildShelfStatusIndicator(shelf),
      title: Text(shelf.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLastSeenTime(shelf),
          Text('IP: ${shelf.ipAddress ?? 'N/A'}'),
        ],
      ),
      trailing: _buildProductInfo(shelf),
    );
  }

  Widget _buildShelfStatusIndicator(SenseShelfModel shelf) {
    Color statusColor;
    if (shelf.lastSeen == null) {
      statusColor = Colors.grey;
    } else {
      final timeDifference =
          DateTime.now().difference(DateTime.parse(shelf.lastSeen!));
      if (timeDifference.inMinutes < 5) {
        statusColor = Colors.green;
      } else if (timeDifference.inHours < 1) {
        statusColor = Colors.yellow;
      } else {
        statusColor = Colors.red;
      }
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: statusColor,
      ),
    );
  }

  Widget _buildLastSeenTime(SenseShelfModel shelf) {
    if (shelf.lastSeen == null) return const SizedBox.shrink();
    final lastSeenTime = DateTime.parse(shelf.lastSeen!);
    return Row(
      children: [
        const Icon(Icons.access_time, size: 16),
        const SizedBox(width: 4),
        Text(DateFormat('MMM d, h:mm a').format(lastSeenTime)),
      ],
    );
  }

  Widget _buildProductInfo(SenseShelfModel shelf) {
    if (shelf.currentUpc == null) return const SizedBox.shrink();
    return FutureBuilder<ProductDetails?>(
      future: _productService
          .getProductDetails(shelf.currentUpc!)
          .then((value) => ProductDetails.fromJson(value)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (snapshot.data!.images.isNotEmpty)
                Image.network(
                  snapshot.data!.images[0],
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 8),
              if (shelf.currentQuantity != null)
                Text('Qty: ${shelf.currentQuantity}'),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
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

  Widget _settingsButton(BuildContext context, FacilityLayoutModel layout) {
    return IconButton(
      onPressed: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FacilityLayoutSettingsScreen(
              layout: layout,
              onDelete: () async {
                try {
                  await FacilityLayoutService()
                      .deleteFacilityLayout(widget.facility.uid, layout.uid);
                  Provider.of<FacilityLayoutProvider>(context, listen: false)
                      .removeLayout(layout.uid);

                  if (layout.parentId != null && layout.parentId!.isNotEmpty) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => FacilityLayoutScreen(
                          layout: _facilityLayoutProvider
                              .findLayoutByUid(layout.parentId!)!,
                          facility: widget.facility,
                        ),
                      ),
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => FacilityScreen(
                            facilityId: widget.facility.uid,
                            title: widget.facility.name),
                      ),
                      (route) => false,
                    );
                  }
                  SenseRxSnackbar(
                    context: context,
                    title: "Success",
                    message: "Layout has been deleted",
                    isSuccess: true,
                  ).show();
                } catch (e) {
                  SenseRxSnackbar(
                    context: context,
                    title: "Error",
                    message: "Failed to delete layout",
                    isError: true,
                  ).show();
                }
              },
            ),
          ),
        );
      },
      icon: const Icon(Icons.settings, color: Colors.white, size: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FacilityLayoutProvider>(
        builder: (context, facilityLayoutProvider, _) {
      final currentLayout =
          facilityLayoutProvider.findLayoutByUid(widget.layout.uid) ??
              widget.layout;
      return BackgroundScaffold(
        appBar: AppBar(
          title: Text(currentLayout.name),
          actions: [_settingsButton(context, currentLayout)],
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
                                Text('(${currentLayout.children?.length ?? 0})',
                                    style: AppTheme
                                        .themeData.textTheme.bodyMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20)),
                                const SizedBox(width: 8),
                                Text('Layouts',
                                    style: AppTheme
                                        .themeData.textTheme.bodyMedium
                                        ?.copyWith(fontSize: 20)),
                              ])),
                          Tab(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                Text('(${currentLayout.shelves?.length ?? 0})',
                                    style: AppTheme
                                        .themeData.textTheme.bodyMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20)),
                                const SizedBox(width: 8),
                                Text('Shelves',
                                    style: AppTheme
                                        .themeData.textTheme.bodyMedium
                                        ?.copyWith(fontSize: 20))
                              ])),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            ListView.builder(
                              itemCount: currentLayout.children?.length ?? 0,
                              itemBuilder: (context, index) {
                                return _buildChildLayoutTile(
                                  context,
                                  _facilityLayoutProvider.layouts.firstWhere(
                                    (element) =>
                                        element.uid ==
                                        currentLayout.children![index].uid,
                                    orElse: () =>
                                        currentLayout.children![index],
                                  ),
                                );
                              },
                            ),
                            ListView.builder(
                              itemCount: currentLayout.shelves?.length ?? 0,
                              itemBuilder: (context, index) {
                                return _buildShelfLayoutTile(
                                    context, currentLayout.shelves![index]);
                              },
                            ),
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
    });
  }
}
