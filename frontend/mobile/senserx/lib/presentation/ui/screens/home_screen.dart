import 'dart:ui';

import 'package:senserx/application/products/barcode_scanner.dart';
import 'package:senserx/application/products/product_service.dart';
import 'package:senserx/domain/models/products/product_details.dart';
import 'package:senserx/presentation/ui/components/common/display/background_scaffold.dart';
import 'package:senserx/presentation/ui/components/common/display/body_wrapper.dart';
import 'package:senserx/presentation/ui/components/common/buttons/primary_button.dart';
import 'package:senserx/presentation/ui/components/common/display/senserx_card.dart';
import 'package:senserx/presentation/ui/components/common/notifications/senserx_snackbar.dart';
import 'package:senserx/presentation/theme/app_theme.dart';
import 'package:senserx/presentation/ui/dialogs/barcode_scanner_dialog.dart';
import 'package:senserx/presentation/providers/application/mode_provider.dart';
import 'package:senserx/presentation/ui/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/enums/operation_mode.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isScanning = false;
  final ProductService _productService = ProductService();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isDragging = false;
  double _dragPercent = 0.0;
  final double _dragThreshold = 0.4;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _scanAndFetchProductDetails() async {
    try {
      BarcodeScanner barcodeScanner = BarcodeScanner();
      setState(() {
        isScanning = true;
      });
      final product = await barcodeScanner.scanAndFetchProductDetails(context);
      if(product == null) throw ArgumentError("Test");
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductDetailsScreen(product: product),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
    } catch (e, s) {
      setState(() {
        isScanning = false;
      });
      SenseRxSnackbar(
              context: context,
              title: "Error",
              message: "An error occurred fetching data on this product",
              isError: true)
          .show();
      rethrow;
    }
  }

  Widget _buildLargeSwitch(ModeProvider modeProvider) {
    final isCheckin = modeProvider.currentMode == OperationMode.checkin;
    const totalWidth = 233.0;
    const buttonWidth = 70.0;
    const padding = 15.0;

    const startPosition = padding;
    const endPosition = totalWidth - buttonWidth - padding;

    final checkinColor = AppTheme.themeData.primaryColor;
    final checkoutColor = Colors.grey.shade400;
    final activeTextColor = AppTheme.themeData.primaryColor;
    const inactiveTextColor = Colors.transparent;

    if (isCheckin && !_isDragging) {
      _animationController.forward();
    } else if (!isCheckin && !_isDragging) {
      _animationController.reverse();
    }

    return GestureDetector(
      onHorizontalDragStart: (_) {
        setState(() {
          _isDragging = true;
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragPercent += details.delta.dx / (endPosition - startPosition);
          _dragPercent = _dragPercent.clamp(0.0, 1.0);
          _animationController.value = _dragPercent;
        });
      },
      onHorizontalDragEnd: (_) {
        setState(() {
          _isDragging = false;
          if (_dragPercent > _dragThreshold && !isCheckin) {
            modeProvider.toggleMode();
            _animationController.forward();
          } else if (_dragPercent < (1 - _dragThreshold) && isCheckin) {
            modeProvider.toggleMode();
            _animationController.reverse();
          } else {
            _animationController.animateTo(isCheckin ? 1.0 : 0.0);
          }
        });
      },
      onTap: () {
        modeProvider.toggleMode();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final backgroundColor = Color.lerp(
              checkoutColor, checkinColor, _animationController.value)!;
          final checkoutTextColor = Color.lerp(
              activeTextColor, inactiveTextColor, _animationController.value)!;
          final checkinTextColor = Color.lerp(
              inactiveTextColor, activeTextColor, _animationController.value)!;

          return Container(
            width: totalWidth,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: startPosition +
                      (_animationController.value *
                          (endPosition - startPosition)),
                  top: 5,
                  child: Container(
                    width: buttonWidth,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(checkoutColor, checkinColor,
                          1 - _animationController.value),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                        child: Icon(
                            isCheckin
                                ? Icons.assignment_turned_in
                                : Icons.assignment_returned,
                            color: isCheckin
                                ? AppTheme.themeData.primaryColor
                                : Colors.white)),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: padding),
                        child: Text(
                          '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: checkoutTextColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: padding),
                        child: Text(
                          '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: checkinTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                icon: const Icon(Icons.settings, size: 32))
          ],
        ),
        body: BodyWrapper(
            child: Center(
          child: SenseRxCard(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Consumer<ModeProvider>(
                builder: (context, modeProvider, child) {
                  return Text(
                    modeProvider.isCheckinMode ? "RECEIVE" : "DISPENSE",
                    style: AppTheme.themeData.textTheme.displayLarge,
                  );
                },
              ),
              const SizedBox(height: 30),
              Consumer<ModeProvider>(
                builder: (context, modeProvider, child) {
                  return _buildLargeSwitch(modeProvider);
                },
              ),
              const SizedBox(height: 75),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton.icon(
                    icon: const Icon(Icons.radar_outlined),
                    label: const Text("Scan Barcode"),
                    onPressed: _scanAndFetchProductDetails
                ),
              )
            ],
          ),
        )));
  }
}
