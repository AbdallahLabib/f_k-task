import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/orders_bloc.dart';

class StatusFilter extends StatelessWidget {
  final String selectedStatus;
  final String searchQuery;
  final bool? isActive;
  final double? minPrice;
  final double? maxPrice;
  final String company;

  const StatusFilter({
    super.key,
    required this.selectedStatus,
    required this.searchQuery,
    required this.isActive,
    required this.minPrice,
    required this.maxPrice,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selectedStatus.isEmpty ? null : selectedStatus,
      onSelected: (String status) {
        // If selecting the same status or empty status, clear the filter
        final newStatus =
            (status.isEmpty || status == selectedStatus) ? '' : status;
        context.read<OrdersBloc>().add(FilterOrders(
              searchQuery: searchQuery,
              isActive: isActive,
              status: newStatus,
              minPrice: minPrice,
              maxPrice: maxPrice,
              company: company,
            ));
      },
      position: PopupMenuPosition.under,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedStatus.isEmpty ? 'Select Status' : selectedStatus,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.grey,
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: '',
          child: Row(
            children: [
              Icon(Icons.clear, color: Colors.red),
              SizedBox(width: 8),
              Text('Clear Filter'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'ORDERED',
          child: Row(
            children: [
              Icon(Icons.hourglass_empty, color: Colors.orange),
              SizedBox(width: 8),
              Text('ORDERED'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'PENDING',
          child: Row(
            children: [
              Icon(Icons.hourglass_empty, color: Colors.orange),
              SizedBox(width: 8),
              Text('PENDING'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'SHIPPED',
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('SHIPPED'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'DELIVERED',
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('DELIVERED'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'RETURNED',
          child: Row(
            children: [
              Icon(Icons.cancel, color: Colors.red),
              SizedBox(width: 8),
              Text('RETURNED'),
            ],
          ),
        ),
      ],
    );
  }
}
