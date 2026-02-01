import 'package:flutter/material.dart';

class FilterIconButton<T> extends StatefulWidget {
  final Key widgetKey;
  final String tooltipMessage;
  final bool hasSelectedValues;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final List<T> items;
  final List<dynamic> selectedValues;
  final String Function(T) fieldExtractor;
  final void Function(List<dynamic>) onUpdate;
  final String title;

  const FilterIconButton({
    required this.widgetKey,
    required this.tooltipMessage,
    required this.hasSelectedValues,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.items,
    required this.selectedValues,
    required this.fieldExtractor,
    required this.onUpdate,
    required this.title,
  }) : super(key: widgetKey);

  @override
  _FilterIconButtonState<T> createState() => _FilterIconButtonState<T>();
}

class _FilterIconButtonState<T> extends State<FilterIconButton<T>> {
  late List<dynamic> temporarySelectedValues = [];

  @override
  void initState() {
    super.initState();
    temporarySelectedValues =
        List.from(widget.selectedValues); // Copy the current selected values
  }

  void _showFilterDialog(Offset offset) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        String searchQuery = '';
        bool isChecked = temporarySelectedValues.length == widget.items.length;
        bool isFiltered = widget.items.isNotEmpty;

        return StatefulBuilder(
          builder: (BuildContext context,
              void Function(void Function()) setStateDialog) {
            final filteredItems = widget.items.where((item) {
              final value = widget.fieldExtractor(item).toLowerCase();
              return value.contains(searchQuery.toLowerCase());
            }).toList();

            final distinctFilteredItems = {
              for (var item in filteredItems) widget.fieldExtractor(item): item
            }.values.toList();

            bool isClearButtonEnabled = temporarySelectedValues.isNotEmpty;

            return Stack(
              children: [
                Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  child: Material(
                    borderRadius: BorderRadius.circular(8),
                    elevation: 8,
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.filter_alt_off_outlined),
                                    tooltip: "Clear Filter",
                                    onPressed: widget.selectedValues.isNotEmpty
                                        ? () {
                                            setStateDialog(() {
                                              if (temporarySelectedValues
                                                  .isNotEmpty) {
                                                temporarySelectedValues.clear();
                                                widget.selectedValues.clear();
                                                isChecked = false;
                                                searchQuery = '';
                                                widget.onUpdate(
                                                    widget.selectedValues);
                                                Navigator.of(context).pop();
                                              }
                                            });
                                          }
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    tooltip: "Close",
                                    onPressed: () {
                                      if (widget.selectedValues.isEmpty) {
                                        temporarySelectedValues.clear();
                                        Navigator.of(context).pop();
                                      } else {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (query) {
                              setStateDialog(() {
                                searchQuery = query;
                              });
                            },
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setStateDialog(() {
                                    isChecked = value ?? false;
                                    if (isChecked) {
                                      // If "Select All" is checked, select all filtered items
                                      temporarySelectedValues.clear();
                                      temporarySelectedValues.addAll(
                                          distinctFilteredItems.map((item) =>
                                              widget.fieldExtractor(item)));
                                    } else {
                                      // Otherwise, clear all selected items
                                      temporarySelectedValues.clear();
                                    }
                                  });
                                },
                              ),
                              const Text('Select All'),
                            ],
                          ),
                          filteredItems.isNotEmpty
                              ? SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: distinctFilteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = distinctFilteredItems[index];
                                      final value = widget.fieldExtractor(item);
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Checkbox(
                                            value: temporarySelectedValues
                                                .contains(value),
                                            onChanged: (bool? selected) {
                                              setStateDialog(() {
                                                if (selected == true) {
                                                  temporarySelectedValues
                                                      .add(value);
                                                } else {
                                                  temporarySelectedValues
                                                      .remove(value);
                                                }

                                                // Update isChecked based on the new selected values

                                                isChecked =
                                                    temporarySelectedValues
                                                            .length ==
                                                        distinctFilteredItems
                                                            .length;
                                              });
                                            },
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(value),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                )
                              : const Center(child: Text('No items found')),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  if (widget.selectedValues.isNotEmpty) {
                                    Navigator.of(context).pop();
                                  } else {
                                    temporarySelectedValues.clear();

                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Apply the filter by updating the selected values
                                  if (temporarySelectedValues.isNotEmpty) {
                                    widget.onUpdate(temporarySelectedValues);
                                    Navigator.of(context).pop();
                                  } else {
                                    widget.selectedValues.clear();
                                    isChecked = false;
                                    searchQuery = '';
                                    widget.onUpdate(widget.selectedValues);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: widget.widgetKey,
      icon: Tooltip(
        message: widget.tooltipMessage,
        child: Icon(
          widget.hasSelectedValues ? widget.activeIcon : widget.inactiveIcon,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onPressed: () {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset offset = box.localToGlobal(Offset.zero);
        _showFilterDialog(offset);
      },
    );
  }
}
