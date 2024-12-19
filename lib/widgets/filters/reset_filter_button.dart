import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/orders_bloc.dart';

class ResetFilterButton extends StatelessWidget {
  final bool hasFilters;

  const ResetFilterButton({
    super.key,
    required this.hasFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasFilters) return const SizedBox.shrink();

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: 1.0,
      child: FilledButton.tonal(
        onPressed: () {
          context.read<OrdersBloc>().add(FilterOrders(
                searchQuery: '',
                isActive: null,
                status: '',
                minPrice: null,
                maxPrice: null,
                company: '',
              ));
        },
        style: FilledButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.grey[700],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear_all, size: 20),
            SizedBox(width: 8),
            Text('Reset Filter'),
          ],
        ),
      ),
    );
  }
}
