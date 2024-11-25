import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:senserx/domain/models/facility/sense_shelf_model.dart';
import 'package:senserx/domain/models/offline/facility_layout_option.dart';
import 'package:senserx/infrastructure/storage/offline_storage.dart';
import 'package:senserx/presentation/providers/application/snackbar_provider.dart';
import 'package:senserx/presentation/ui/components/common/buttons/cancel_button.dart';
import 'package:senserx/presentation/ui/components/common/buttons/primary_button.dart';
import 'package:senserx/presentation/ui/components/common/display/senserx_card.dart';
import 'package:senserx/presentation/ui/components/common/inputs/senserx_filter_list.dart';

import '../../../theme/app_theme.dart';

class ShelfProvisioningForm extends StatefulWidget {
  final String? initialLayoutId;
  final SenseShelfModel? shelf;

  const ShelfProvisioningForm({super.key, this.initialLayoutId, this.shelf});

  @override
  State<ShelfProvisioningForm> createState() => _ShelfProvisioningFormState();
}

class _ShelfProvisioningFormState extends State<ShelfProvisioningForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shelfNameController = TextEditingController();
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isLoading = false;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  String facilityId = dotenv.env['FACILITY_ID'] ?? "";
  FacilityLayoutOption? _selectedLayout;
  FacilityLayoutOption? _initialFacilityLayoutOption;
  List<FacilityLayoutOption> _facilityLayouts = [];
  final OfflineStorage _storageService = OfflineStorage();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _facilityLayouts = _storageService.getFacilityLayouts();
    _fetchSSID();

    if (widget.shelf != null) {
      setState(() {
        _shelfNameController.text = widget.shelf?.name ?? "";
      });
    }

    if (widget.initialLayoutId != null && _facilityLayouts.isNotEmpty) {
      setState(() {
        _selectedLayout = _facilityLayouts.firstWhere(
          (layout) => layout.uid == widget.initialLayoutId,
        );
        _initialFacilityLayoutOption = _selectedLayout;
      });
    }
  }

  Future<void> _fetchSSID() async {
    final wifiName = await NetworkInfo().getWifiName();
    setState(() {
      _ssidController.text = wifiName?.trim().replaceAll("\"", "") ?? '';
      _isLoading = false;
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shelfNameController.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onConnectPressed() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      final ssid = _ssidController.text;
      final password = _passwordController.text;
      final deviceName = _shelfNameController.text;
      if (_selectedLayout == null) throw ArgumentError(_selectedLayout);

      final Map<String, String> payload = {
        'deviceName': deviceName.trim().replaceAll("\"", ""),
        'ssid': ssid,
        'password': password,
        'facilityId': facilityId,
        'facilityLayoutId': _selectedLayout!.uid,
      };

      try {
        var host = widget.shelf != null
            ? 'https://${widget.shelf!.ipAddress}'
            : dotenv.env['SHELF_AP_HOST'];
        final response = await http.post(
          Uri.parse('$host/provision'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );
        setState(() {
          isLoading = false;
        });
        if (response.statusCode == 200) {
          context.read<SnackbarProvider>().showSnackbar(
              "WiFi provisioning started.",
              isSuccess: true,
              title: "Success");
        } else {
          context.read<SnackbarProvider>().showSnackbar(
              "Provisioning failed. Please try again",
              isError: true);
        }
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        context
            .read<SnackbarProvider>()
            .showSnackbar(e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? formTextStyle = AppTheme.themeData.textTheme.bodyMedium
        ?.copyWith(fontWeight: FontWeight.w500);
    return FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi,
                      size: 40, color: AppTheme.themeData.primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    'SenseRx Shelf',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.themeData.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shelf Name Field
                      const Text(
                        'Shelf Name',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style: formTextStyle,
                        controller: _shelfNameController,
                        decoration: InputDecoration(
                          labelText: 'Assign a name to this shelf',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          labelStyle: formTextStyle,
                          fillColor: Colors.grey[200],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a shelf name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // WiFi Network Section
                      const Text(
                        'WiFi Network',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style: formTextStyle,
                        controller: _ssidController,
                        decoration: InputDecoration(
                          labelText: 'WiFi network name',
                          labelStyle: formTextStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an network name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: formTextStyle,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'WiFi network password',
                          labelStyle: formTextStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Facility Layout',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      FormField<FacilityLayoutOption>(
                        validator: (value) {
                          if (_selectedLayout == null) {
                            return 'Please select a facility layout';
                          }
                          return null;
                        },
                        builder: (FormFieldState<FacilityLayoutOption> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SenseRxFilterList<FacilityLayoutOption>(
                                items: _facilityLayouts,
                                itemAsString: (layout) => layout.name,
                                initialValue: _selectedLayout,
                                onChanged: (layout) {
                                  setState(() {
                                    _selectedLayout = layout;
                                  });
                                  state.didChange(layout);
                                },
                                hintText: 'Select a facility layout',
                                isRequired: true,
                                error: state.hasError,
                              ),
                              if (state.hasError)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, left: 8),
                                  child: Text(
                                    state.errorText!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          isLoading: isLoading,
                          onPressed: _onConnectPressed,
                          text: 'Connect',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(
                        width: double.infinity,
                        child: CancelButton(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ));
  }
}
