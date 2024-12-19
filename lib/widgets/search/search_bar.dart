import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/orders_bloc.dart';

class SearchTextField extends StatelessWidget {
  final String searchQuery;
  final bool? isActive;
  final String status;
  final double? minPrice;
  final double? maxPrice;
  final String company;
  final Function(String)? onChanged;
  final String? hintText;

  const SearchTextField({
    super.key,
    required this.searchQuery,
    required this.isActive,
    required this.status,
    required this.minPrice,
    required this.maxPrice,
    required this.company,
    this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white24,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: TextEditingController(text: searchQuery)
          ..selection = TextSelection.fromPosition(
              TextPosition(offset: searchQuery.length)),
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value);
          } else {
            context.read<OrdersBloc>().add(FilterOrders(
                  searchQuery: value,
                  isActive: isActive,
                  status: status,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                  company: company,
                ));
          }
        },
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText ?? 'Search by buyer, company, or tags...',
          hintStyle: const TextStyle(color: Colors.white),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
