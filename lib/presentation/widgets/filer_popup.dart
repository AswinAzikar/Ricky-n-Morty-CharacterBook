import 'package:flutter/material.dart';
import 'package:new_app/data/models/filter_options.dart';
import 'package:new_app/presentation/constants/constColors.dart';

class FilterPopup extends StatefulWidget {
  final FilterOptions filterOptions;
  final Function(Map<String, List<String>>) onFiltersSelected;

  const FilterPopup({
    required this.filterOptions,
    required this.onFiltersSelected,
  });

  @override
  _FilterPopupState createState() => _FilterPopupState();
}

class _FilterPopupState extends State<FilterPopup> {
  Map<String, List<String>> selectedFilters = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter By'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildFilterSection(
              'Status',
              widget.filterOptions.statusOptions,
              (selectedOptions) {
                selectedFilters['status'] = selectedOptions;
              },
            ),
            _buildFilterSection(
              'Species',
              widget.filterOptions.speciesOptions,
              (selectedOptions) {
                selectedFilters['species'] = selectedOptions;
              },
            ),
            _buildFilterSection(
              'Gender',
              widget.filterOptions.genderOptions,
              (selectedOptions) {
                selectedFilters['gender'] = selectedOptions;
              },
            ),
            ElevatedButton(
              onPressed: () {
                widget.onFiltersSelected(selectedFilters);
                Navigator.of(context).pop();
              },
              child: Text(
                'Apply Filters',
                style: TextStyle(),
              ),
              style: ButtonStyle(
                shape: WidgetStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide.none,
                  ),
                ),
                backgroundColor:
                    WidgetStateProperty.all<Color>(AppColors.Secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String label,
    List<String> options,
    Function(List<String>) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Column(
          children: options.map((option) {
            return CheckboxListTile(
              title: Text(option),
              value: selectedFilters[label]?.contains(option) ?? false,
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    selectedFilters[label] = [
                      ...(selectedFilters[label] ?? []),
                      option
                    ];
                  } else {
                    selectedFilters[label]?.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
