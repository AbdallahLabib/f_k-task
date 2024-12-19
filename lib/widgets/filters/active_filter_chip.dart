import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/orders_bloc.dart';

class ActiveFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool? isActive;
  final String searchQuery;
  final String status;
  final double? minPrice;
  final double? maxPrice;
  final String company;

  const ActiveFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.isActive,
    required this.searchQuery,
    required this.status,
    required this.minPrice,
    required this.maxPrice,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey[700],
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onSelected: (selected) {
        context.read<OrdersBloc>().add(FilterOrders(
              searchQuery: searchQuery,
              isActive: selected ? isActive : null,
              status: status,
              minPrice: minPrice,
              maxPrice: maxPrice,
              company: company,
            ));
      },
      selectedColor: theme.primaryColor,
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
      elevation: 2,
      pressElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? theme.primaryColor : Colors.grey[300]!,
          width: 1,
        ),
      ),
    );
  }
}
