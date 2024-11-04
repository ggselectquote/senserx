import 'package:senserx/domain/enums/operation_mode.dart';
import 'package:senserx/domain/models/checkout_checkin_details.dart';
import 'package:senserx/presentation/ui/components/common/buttons/cancel_button.dart';
import 'package:senserx/presentation/ui/components/common/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantityInputSheet extends StatefulWidget {
  final ScrollController scrollController;
  final double defaultQuantity;
  final String ndc;
  final OperationMode operationMode;

  const QuantityInputSheet(
      {super.key,
      required this.scrollController,
      this.defaultQuantity = 0.0,
      required this.ndc,
      required this.operationMode});

  @override
  _QuantityInputSheetState createState() => _QuantityInputSheetState();
}

class _QuantityInputSheetState extends State<QuantityInputSheet> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      double? quantity = double.tryParse(_controller.text);
      if (quantity != null) {
        Navigator.pop(
            context,
            CheckoutCheckinDetails(
                quantity: quantity,
                ndc: widget.ndc,
                mode: widget.operationMode));
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
                  "${widget.operationMode == OperationMode.checkin ? "Checkin" : "Checkout"} Quantity",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    text: "Confirm",
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
