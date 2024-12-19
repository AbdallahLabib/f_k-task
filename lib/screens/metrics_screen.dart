import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flapkap_task/blocs/orders_bloc.dart';
import 'package:flapkap_task/constants/colors.dart';
import 'package:flapkap_task/widgets/search/search_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../widgets/filters/active_filter_chip.dart';
import '../widgets/filters/status_filter.dart';
import '../widgets/filters/reset_filter_button.dart';
import '../widgets/filters/tags_filter.dart';
import '../widgets/metrics/metric_card.dart';
import '../widgets/orders/order_card.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoaded) {
            return Stack(
              children: [
                Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.5,
                            child: _buildChart(),
                          ),
                          Divider(color: Colors.grey[600]),
                          const SizedBox(height: 10),
                          _buildSearchAndFilters(state, context),
                          const SizedBox(height: 32),
                          if (state.hasActiveFilters)
                            _buildFilteredOrdersHeader(state, context),
                          _buildMetrics(state),
                          const SizedBox(height: 10),
                          _buildOrdersList(state, context),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          } else if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('Error loading orders'));
          }
        },
      ),
    );
  }

  List<FlSpot> _createSpots(List<Order> orders) {
    final Map<DateTime, int> orderCounts = {};

    // Group orders by day
    for (var order in orders) {
      final dateKey = DateTime(
          order.registered.year, order.registered.month, order.registered.day);
      orderCounts[dateKey] = (orderCounts[dateKey] ?? 0) + 1;
    }

    // Sort dates and create spots
    final sortedDates = orderCounts.keys.toList()..sort();
    return sortedDates.map((date) {
      return FlSpot(
        date.millisecondsSinceEpoch.toDouble(),
        orderCounts[date]!.toDouble(), // Ensure integer values for Y
      );
    }).toList();
  }

  double _calculateDateInterval(List<Order> orders) {
    if (orders.isEmpty) return 1;

    final dates = orders.map((o) => o.registered).toList();
    final minDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    final totalDays = maxDate.difference(minDate).inDays + 1;
    final isMobile = kIsWeb ? false : Platform.isAndroid || Platform.isIOS;
    // Show approximately 12 labels instead of 8
    return (totalDays / 12).ceil() * 24 * 60 * 60 * (isMobile ? 200 : 1000);
  }

  Widget _buildChart() {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoaded) {
          if (state.orders.isEmpty) {
            return Center(
              child: Text(
                'No orders available',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            );
          }

          final isMobile =
              kIsWeb ? false : Platform.isAndroid || Platform.isIOS;

          return Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: isMobile
                      ? state.orders.length * 40.0
                      : MediaQuery.sizeOf(context).width,
                  child: LineChart(LineChartData(
                    lineTouchData: LineTouchData(
                      touchCallback: (FlTouchEvent event,
                          LineTouchResponse? touchResponse) {
                        if (touchResponse != null &&
                            touchResponse.lineBarSpots != null &&
                            touchResponse.lineBarSpots!.isNotEmpty) {
                          final touchedSpot = touchResponse.lineBarSpots!.first;
                          final touchedDate =
                              DateTime.fromMillisecondsSinceEpoch(
                                  touchedSpot.x.toInt());
                          final ordersOnDate = state.orders
                              .where((order) =>
                                  order.registered.year == touchedDate.year &&
                                  order.registered.month == touchedDate.month &&
                                  order.registered.day == touchedDate.day)
                              .toList();
                          final orderCount = ordersOnDate.length;

                          // Format the message
                          final message = orderCount == 1
                              ? '1 order'
                              : '$orderCount orders';

                          // Show the message
                          print('Orders on $touchedDate: $message');
                        }
                      },
                      handleBuiltInTouches: true, // Keep default touch behavior
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(), // Display whole numbers
                              style: GoogleFonts.poppins(
                                  color: Colors.grey[600], fontSize: 12),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: _calculateDateInterval(state.orders),
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('MMM d').format(date),
                                style: GoogleFonts.poppins(
                                    color: Colors.grey[600], fontSize: 11),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              // Display rounded numbers
                              value.round().toString(),
                              style: GoogleFonts.poppins(
                                  color: Colors.transparent, fontSize: 12),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.grey[300]!), // Keep bottom border
                        left: BorderSide(
                            color: Colors.grey[300]!), // Keep left border
                        top: BorderSide
                            .none, // Remove top border to avoid padding
                        right: BorderSide.none, // Remove right border
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _createSpots(state.orders),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        preventCurveOverShooting: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 2,
                              strokeColor: Colors.blue,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: false,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            ),
          );
        }

        if (state is OrdersError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        if (state is OrdersInitial || state is OrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return const Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _buildFilteredOrdersHeader(OrdersLoaded state, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filtered Orders (${state.filteredOrders.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Total Orders: ${state.orders.length}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOrdersList(OrdersLoaded state, BuildContext context) {
    if (state.filteredOrders.isEmpty && state.hasActiveFilters) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders match your filters.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: state.filteredOrders.length,
      itemBuilder: (context, index) {
        final order = state.filteredOrders[index];
        return OrderCard(order: order);
      },
    );
  }

  List<String> _getAllUniqueTags(List<Order> orders) {
    final tags = <String>{};
    for (var order in orders) {
      tags.addAll(order.tags);
    }
    return tags.toList()..sort();
  }

  Widget _buildSearchAndFilters(OrdersLoaded state, BuildContext context) {
    final uniqueTags = _getAllUniqueTags(state.orders);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TagsFilter(
          tags: uniqueTags,
          searchQuery: state.searchQuery,
          isActive: state.isActive,
          status: state.status,
          minPrice: state.minPrice,
          maxPrice: state.maxPrice,
          company: state.company,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SearchTextField(
                searchQuery: state.searchQuery,
                isActive: state.isActive,
                status: state.status,
                minPrice: state.minPrice,
                maxPrice: state.maxPrice,
                company: state.company,
              ),
            ),
            if (state.hasActiveFilters) ...[
              const SizedBox(width: 8),
              ResetFilterButton(hasFilters: state.hasActiveFilters),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            StatusFilter(
              selectedStatus: state.status,
              searchQuery: state.searchQuery,
              isActive: state.isActive,
              minPrice: state.minPrice,
              maxPrice: state.maxPrice,
              company: state.company,
            ),
            ActiveFilterChip(
              label: 'Active Orders',
              selected: state.isActive == true,
              isActive: true,
              searchQuery: state.searchQuery,
              status: state.status,
              minPrice: state.minPrice,
              maxPrice: state.maxPrice,
              company: state.company,
            ),
            ActiveFilterChip(
              label: 'Inactive Orders',
              selected: state.isActive == false,
              isActive: false,
              searchQuery: state.searchQuery,
              status: state.status,
              minPrice: state.minPrice,
              maxPrice: state.maxPrice,
              company: state.company,
            ),
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  final minPrice = double.tryParse(value);
                  context.read<OrdersBloc>().add(FilterOrders(
                        searchQuery: state.searchQuery,
                        isActive: state.isActive,
                        status: state.status,
                        minPrice: minPrice,
                        maxPrice: state.maxPrice,
                        company: state.company,
                      ));
                },
                style: const TextStyle(color: AppColors.primary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Min Price',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: InputBorder.none,
                  constraints: const BoxConstraints(maxWidth: 100),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  final maxPrice = double.tryParse(value);
                  context.read<OrdersBloc>().add(FilterOrders(
                        searchQuery: state.searchQuery,
                        isActive: state.isActive,
                        status: state.status,
                        minPrice: state.minPrice,
                        maxPrice: maxPrice,
                        company: state.company,
                      ));
                },
                style: const TextStyle(color: AppColors.primary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Max Price',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: InputBorder.none,
                  constraints: const BoxConstraints(maxWidth: 100),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetrics(OrdersLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if the screen width is small (e.g., mobile view)
        final isMobile = kIsWeb ? false : Platform.isAndroid || Platform.isIOS;

        if (isMobile) {
          const cardWidth = 200.0;
          const cardHeight = 100.0;
          const spacing = 16.0;
          // Horizontal scroll view for mobile
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : spacing,
                    right: index == 3 ? spacing : 0,
                  ),
                  child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: _buildMetricCard(index, state),
                  ),
                ),
              ),
            ),
          );
        } else {
          const cardWidth = 200.0;
          const cardHeight = 150.0;
          const spacing = 16.0;
          final cardsPerRow =
              (constraints.maxWidth + spacing) ~/ (cardWidth + spacing);
          final rows = (4 / cardsPerRow).ceil();
          final height = rows * cardHeight + (rows - 1) * spacing;

          return SizedBox(
            height: height,
            child: Stack(
              children: List.generate(
                4,
                (index) {
                  final row = index ~/ cardsPerRow;
                  final col = index % cardsPerRow;
                  final x = col * (cardWidth + spacing);
                  final y = row * (cardHeight + spacing);

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOut,
                    left: x,
                    top: y,
                    child: AnimatedScale(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      scale: 1.0,
                      curve: Curves.easeOutBack,
                      child: SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: _buildMetricCard(index, state),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildMetricCard(int index, OrdersLoaded state) {
    switch (index) {
      case 0:
        return MetricCard(
          title: 'Total Orders',
          value: state.totalOrders.toString(),
          icon: Icons.shopping_cart,
          color: Colors.blue[700]!,
        );
      case 1:
        return MetricCard(
          title: 'Average Price',
          value: '\$${state.averageOrderPrice.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.green[700]!,
        );
      case 2:
        return MetricCard(
          title: 'Returns',
          value: state.returnsCount.toString(),
          icon: Icons.assignment_return,
          color: Colors.orange[700]!,
        );
      case 3:
        final successRate = state.totalOrders > 0
            ? ((state.totalOrders - state.returnsCount) /
                state.totalOrders *
                100)
            : 0.0;
        return MetricCard(
          title: 'Success Rate',
          value: '${successRate.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: Colors.purple[700]!,
        );
      default:
        return const SizedBox();
    }
  }
}
