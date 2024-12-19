import 'dart:io';

import 'package:flapkap_task/blocs/orders_bloc.dart';
import 'package:flapkap_task/constants/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TagsFilter extends StatefulWidget {
  final List<String> tags;
  final String searchQuery;
  final bool? isActive;
  final String status;
  final double? minPrice;
  final double? maxPrice;
  final String company;

  const TagsFilter({
    super.key,
    required this.tags,
    required this.searchQuery,
    required this.isActive,
    required this.status,
    required this.minPrice,
    required this.maxPrice,
    required this.company,
  });

  @override
  State<TagsFilter> createState() => _TagsFilterState();
}

class _TagsFilterState extends State<TagsFilter>
    with SingleTickerProviderStateMixin {
  final Set<String> _selectedTags = {};
  bool _isExpanded = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _addTag(String tag) {
    setState(() {
      _selectedTags.add(tag);
    });
    _updateFilters();
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
    _updateFilters();
  }

  void _clearAllTags() {
    setState(() {
      _selectedTags.clear();
    });
    _updateFilters();
  }

  void _updateFilters() {
    final ordersBloc = context.read<OrdersBloc>();
    ordersBloc.add(
      FilterOrders(
        searchQuery: _selectedTags.join(' '),
        isActive: widget.isActive,
        status: widget.status,
        minPrice: widget.minPrice,
        maxPrice: widget.maxPrice,
        company: widget.company,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tags.isEmpty) return const SizedBox.shrink();

    final filteredTags = widget.tags
        .where((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    // Check if the screen width is small (e.g., mobile view)
    final isMobile = kIsWeb ? false : Platform.isAndroid || Platform.isIOS;
    final displayTags = _isExpanded
        ? filteredTags
        : filteredTags.take(isMobile ? 3 : 8).toList();
    final hasMoreTags = filteredTags.length > 8;

    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedTags.isNotEmpty) _buildSelectedTags(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterHeader(),
                  // _buildSearchField(),
                  _buildTagChips(displayTags),
                  if (hasMoreTags) _buildShowMoreButton(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedTags() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.label_outline, size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Selected Tags',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTags.map((tag) {
              return Chip(
                label: Text(
                  tag,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
                backgroundColor: Colors.blue,
                deleteIcon: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.primary,
                ),
                onDeleted: () => _removeTag(tag),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          const Icon(Icons.tag, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text(
            'Filter by Tags',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_selectedTags.isNotEmpty) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: _clearAllTags,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                foregroundColor: Colors.red[400],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear, size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('Clear All',
                      style: TextStyle(fontSize: 12, color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget _buildSearchField() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 12),
  //     child: SearchTextField(
  //       hintText: 'Search tags...',
  //       isLoading: false,
  //       onSearch: (query) {
  //         setState(() {
  //           _searchQuery = query;
  //         });
  //       },
  //       onClear: () {
  //         setState(() {
  //           _searchQuery = '';
  //         });
  //       },
  //     ),
  //   );
  // }

  Widget _buildTagChips(List<String> displayTags) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: displayTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(
                tag,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.grey[400],
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _addTag(tag);
                } else {
                  _removeTag(tag);
                }
              },
              backgroundColor: Colors.grey[800],
              selectedColor: Colors.blue,
              checkmarkColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildShowMoreButton() {
    return TextButton(
      onPressed: _toggleExpand,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isExpanded ? 'Show Less' : 'Show More',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 16,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
