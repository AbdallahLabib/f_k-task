// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import '../blocs/orders_bloc.dart';
// import '../models/order.dart';

// class GraphScreen extends StatefulWidget {
//   const GraphScreen({super.key});

//   @override
//   State<GraphScreen> createState() => _GraphScreenState();
// }

// class _GraphScreenState extends State<GraphScreen> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<OrdersBloc>().add(LoadOrders());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Orders Timeline',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 'Number of orders over time',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Expanded(
//                 child: _buildChart(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<FlSpot> _createSpots(List<Order> orders) {
//     final Map<DateTime, int> orderCounts = {};

//     // Group orders by day
//     for (var order in orders) {
//       final dateKey = DateTime(
//           order.registered.year, order.registered.month, order.registered.day);
//       orderCounts[dateKey] = (orderCounts[dateKey] ?? 0) + 1;
//     }

//     // Sort dates and create spots
//     final sortedDates = orderCounts.keys.toList()..sort();
//     return sortedDates.map((date) {
//       return FlSpot(
//         date.millisecondsSinceEpoch.toDouble(),
//         orderCounts[date]!.toDouble(), // Ensure integer values for Y
//       );
//     }).toList();
//   }

//   double _calculateDateInterval(List<Order> orders) {
//     if (orders.isEmpty) return 1;

//     final dates = orders.map((o) => o.registered).toList();
//     final minDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
//     final maxDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

//     final totalDays = maxDate.difference(minDate).inDays + 1;

//     // Show approximately 12 labels instead of 8
//     return (totalDays / 12).ceil() *
//         24 *
//         60 *
//         60 *
//         1000; // Milliseconds in a day
//   }

//   Widget _buildChart() {
//     return BlocBuilder<OrdersBloc, OrdersState>(
//       builder: (context, state) {
//         if (state is OrdersLoaded) {
//           if (state.orders.isEmpty) {
//             return Center(
//               child: Text(
//                 'No orders available',
//                 style: GoogleFonts.poppins(color: Colors.grey),
//               ),
//             );
//           }

//           final isMobile = Platform.isAndroid || Platform.isIOS;

//           return Card(
//             elevation: 4,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: SizedBox(
//                   width:
//                       isMobile ? state.orders.length * 40.0 : double.infinity,
//                   child: LineChart(LineChartData(
//                     titlesData: FlTitlesData(
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           interval: 1,
//                           reservedSize: 40,
//                           getTitlesWidget: (value, meta) {
//                             return Text(
//                               value.toInt().toString(), // Display whole numbers
//                               style: GoogleFonts.poppins(
//                                   color: Colors.grey[600], fontSize: 12),
//                             );
//                           },
//                         ),
//                       ),
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           interval: _calculateDateInterval(state.orders),
//                           getTitlesWidget: (value, meta) {
//                             final date = DateTime.fromMillisecondsSinceEpoch(
//                                 value.toInt());
//                             return Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Text(
//                                 DateFormat('MMM d').format(date),
//                                 style: GoogleFonts.poppins(
//                                     color: Colors.grey[600], fontSize: 11),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       topTitles: const AxisTitles(
//                         sideTitles: SideTitles(showTitles: true),
//                       ),
//                     ),
//                     borderData: FlBorderData(
//                       show: true,
//                       border: Border(
//                         bottom: BorderSide(
//                             color: Colors.grey[300]!), // Keep bottom border
//                         left: BorderSide(
//                             color: Colors.grey[300]!), // Keep left border
//                         top: BorderSide
//                             .none, // Remove top border to avoid padding
//                         right: BorderSide.none, // Remove right border
//                       ),
//                     ),
//                     lineBarsData: [
//                       LineChartBarData(
//                         spots: _createSpots(state.orders),
//                         isCurved: true,
//                         color: Colors.blue,
//                         barWidth: 3,
//                         isStrokeCapRound: true,
//                         dotData: FlDotData(
//                           show: true,
//                           getDotPainter: (spot, percent, barData, index) {
//                             return FlDotCirclePainter(
//                               radius: 4,
//                               color: Colors.white,
//                               strokeWidth: 2,
//                               strokeColor: Colors.blue,
//                             );
//                           },
//                         ),
//                         belowBarData: BarAreaData(
//                           show: true,
//                           color: Colors.blue.withOpacity(0.1),
//                         ),
//                       ),
//                     ],
//                   )),
//                 ),
//               ),
//             ),
//           );
//         }

//         if (state is OrdersError) {
//           return Center(
//             child: Text(
//               'Error: ${state.message}',
//               style: GoogleFonts.poppins(color: Colors.red),
//             ),
//           );
//         }

//         if (state is OrdersInitial || state is OrdersLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return const Center(child: Text('Something went wrong'));
//       },
//     );
//   }
// }
