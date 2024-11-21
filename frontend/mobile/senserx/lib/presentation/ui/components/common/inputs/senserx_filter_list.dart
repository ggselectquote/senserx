import 'package:flutter/material.dart';
import 'package:senserx/presentation/ui/components/common/buttons/cancel_button.dart';
import '../../../../theme/app_theme.dart';

class SenseRxFilterList<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemAsString;
  final IconData Function(T)? itemIcon;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;
  final String hintText;
  final bool isRequired;
  final bool error;
  final List<T> Function(T)? getChildren;
  final T? initialValue;
  final int Function(T)? getDepth;

  const SenseRxFilterList({
    Key? key,
    required this.items,
    required this.itemAsString,
    this.error = false,
    this.itemIcon,
    required this.onChanged,
    this.validator,
    this.hintText = 'Select an item',
    this.isRequired = false,
    this.getChildren,
    this.initialValue,
    this.getDepth,
  }) : super(key: key);

  @override
  _SenseRxFilterListState<T> createState() => _SenseRxFilterListState<T>();
}

class _SenseRxFilterListState<T> extends State<SenseRxFilterList<T>> {
  final TextEditingController _searchController = TextEditingController();
  T? _selectedItem;
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _selectedItem = widget.initialValue;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => widget.itemAsString(item)
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  TextStyle? formLabelText = AppTheme.themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);

  Widget _buildItem(T item, int depth, StateSetter setModalState) {
    final children = widget.getChildren?.call(item) ?? [];
    final itemDepth = widget.getDepth?.call(item) ?? depth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setModalState(() {
              _selectedItem = _selectedItem == item ? null : item;
            });
            setState(() {
              widget.onChanged(_selectedItem);
            });
            Navigator.of(context).pop();
          },
          child: CheckboxListTile(
            value: _selectedItem == item,
            onChanged: (bool? value) {
              setModalState(() {
                _selectedItem = value! ? item : null;
              });
              setState(() {
                widget.onChanged(_selectedItem);
              });

              Navigator.of(context).pop();
            },
            title: Text(widget.itemAsString(item), style: formLabelText),
            secondary: widget.itemIcon != null
                ? Icon(widget.itemIcon!(item), size: 24, color: AppTheme.themeData.primaryColor)
                : null,
            contentPadding: EdgeInsets.only(left: itemDepth > 0 ? 16.0 * itemDepth : 16, right: 16.0),
          ),
        ),
        if (children.isNotEmpty)
          Column(
            children: children.map((child) => _buildItem(child as T, itemDepth + 1, setModalState)).toList(),
          ),
      ],
    );
  }

  void _showFilterList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        style: formLabelText,
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search ${widget.hintText}',
                          hintStyle: formLabelText,
                          labelStyle: formLabelText,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: _filterItems,
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: controller,
                        children: _filteredItems.map((item) => _buildItem(item, 0, setModalState)).toList(),
                      ),
                    ),
                  const  Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: CancelButton()
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    ).then((_) {
      setState(() {
        // Update the main view's state when the modal is dismissed
        widget.onChanged(_selectedItem);
      });
    });;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showFilterList,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: !widget.error ? Colors.black : Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_selectedItem != null && widget.itemIcon != null)
                  Icon(widget.itemIcon!(_selectedItem!), size: 24, color: AppTheme.themeData.primaryColor),
                const SizedBox(width: 4),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Text(
                        _selectedItem != null
                            ? widget.itemAsString(_selectedItem!)
                            : widget.hintText,
                        style: formLabelText,
                      ),
                    )
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (widget.isRequired && widget.validator != null)
          FormField<T>(
            validator: widget.validator,
            builder: (FormFieldState<T> state) {
              return state.hasError
                  ? Text(
                state.errorText!,
                style: const TextStyle(color: Colors.red),
              )
                  : Container();
            },
          ),
      ],
    );
  }
}
