import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:senserx/application/facility/inventory_event_service.dart';
import 'package:senserx/domain/enums/operation_mode.dart';
import 'package:senserx/domain/models/application/checkout_checkin_details.dart';
import 'package:senserx/presentation/ui/components/common/buttons/cancel_button.dart';
import 'package:senserx/presentation/ui/components/common/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senserx/presentation/ui/components/common/notifications/senserx_snackbar.dart';

import '../../../../domain/models/facility/inventory_event_model.dart';

class QuantityInputSheet extends StatefulWidget {
  final ScrollController scrollController;
  final double defaultQuantity;
  final String upc;
  final OperationMode operationMode;

  const QuantityInputSheet(
      {super.key,
      required this.scrollController,
      this.defaultQuantity = 0.0,
      required this.upc,
      required this.operationMode});

  @override
  _QuantityInputSheetState createState() => _QuantityInputSheetState();
}

class _QuantityInputSheetState extends State<QuantityInputSheet> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final InventoryEventService _inventoryEventService = InventoryEventService();
  String facilityId = dotenv.env['FACILITY_ID'] ?? "";

  @override
  void initState() {
    super.initState();
    if (widget.defaultQuantity > 0) {
      _controller.text = widget.defaultQuantity.toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      double? quantity = double.tryParse(_controller.text);
      if (quantity != null && widget.operationMode == OperationMode.checkout) {
        try {
          var response =
              await _inventoryEventService.updateLatestUnconfirmedCheckout(
                  widget.upc, facilityId, quantity);
          print(response);
          Navigator.pop(
              context,
              CheckoutCheckinDetails(
                  quantity: quantity,
                  upc: widget.upc,
                  mode: widget.operationMode));
        } catch (e, s) {
          print(e);
          print(s);
          SenseRxSnackbar(
                  context: context,
                  isError: true,
                  title: "Dispense Failed",
                  message: "There is no waiting dispense event.")
              .show();
        }
      } else if (quantity != null &&
          widget.operationMode == OperationMode.checkin) {
        try {
          var response = await _inventoryEventService
              .createInventoryEvent(InventoryEventModel.fromJson({
            'eventType': 'receive',
            'upc': widget.upc,
            'quantity': quantity,
            'isConfirmed': false,
            'facilityId': facilityId,
            'shelfId': null,
            'facilityLayoutId': null,
            'timestamp': null,
            'confirmedAt': null,
          }));
          print(response);
          Navigator.pop(
              context,
              CheckoutCheckinDetails(
                  quantity: quantity,
                  upc: widget.upc,
                  mode: widget.operationMode));
        } catch (e, s) {
          print(e);
          print(s);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${widget.operationMode == OperationMode.checkin ? "Receive" : "Dispense"} Quantity",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  autofocus: true,
                  onEditingComplete: _submitForm,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Quantity",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: PrimaryButton(
                    text: "Start",
                    onPressed: _submitForm,
                  ),
                ),
                const SizedBox(height: 16),
                const CancelButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
