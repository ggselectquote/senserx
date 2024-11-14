import 'package:senserx/domain/models/application/checkout_checkin_details.dart';
import 'package:senserx/presentation/ui/components/common/buttons/primary_button.dart';
import 'package:senserx/presentation/ui/components/common/display/background_scaffold.dart';
import 'package:senserx/presentation/ui/components/common/buttons/cancel_button.dart';
import 'package:senserx/presentation/ui/components/common/notifications/senserx_snackbar.dart';
import 'package:senserx/presentation/ui/components/products/quantity_input_sheet.dart';
import 'package:senserx/presentation/providers/application/mode_provider.dart';
import 'package:senserx/presentation/theme/app_theme.dart';
import 'package:senserx/domain/models/products/product_details.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class ProductDetailsScreen extends StatelessWidget {
  final ProductDetails product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      body: SafeArea(
        child: Consumer<ModeProvider>(
          builder: (context, modeProvider, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.white.withOpacity(0.9),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      product.images.first,
                                      height: 200,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 20),
                                    Table(
                                      border: TableBorder.all(color: Colors.grey.shade300),
                                      children: [
                                        _buildTableRow('NDC', product.asin),
                                        _buildTableRow('Brand', product.brand),
                                        _buildTableRow('Weight', '${product.weight}/unit'),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                    PrimaryButton(
                                      text: modeProvider.isCheckinMode ? "CHECKIN" : "CHECKOUT",
                                      onPressed: () => _showQuantityInputSheet(context, modeProvider),
                                      textColor: Colors.white,
                                    ),
                                    const SizedBox(height: 20),
                                    const CancelButton(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: AppTheme.themeData.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              value,
              style: AppTheme.themeData.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.normal),
            ),
          ),
        ),
      ],
    );
  }

  void _showQuantityInputSheet(BuildContext context, ModeProvider modeProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.2,
          maxChildSize: 0.75,
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: QuantityInputSheet(
                operationMode: modeProvider.currentMode,
                scrollController: controller,
                defaultQuantity: 1000,
                ndc: product.asin,
              ),
            );
          },
        );
      },
    ).then((value) {
      if (value != null && value is CheckoutCheckinDetails) {
        Navigator.pop(context);
        SenseRxSnackbar(
          durationInSeconds: 5,
          context: context,
          title: "${modeProvider.isCheckinMode ? "Checkin" : "Checkout"} Confirmed",
          message: "${value.ndc} - ${value.quantity} qty.",
          isSuccess: true,
        ).show();
      }
    });
  }
}