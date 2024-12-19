import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart' as injectable;
import '../models/order.dart';

abstract class OrdersRepository {
  Future<List<Order>> getOrders();
}

@injectable.Injectable(as: OrdersRepository)
class OrdersRepositoryImpl implements OrdersRepository {
  @override
  Future<List<Order>> getOrders() async {
    try {
      final String response = await rootBundle.loadString('assets/orders.json');
      final List<dynamic> ordersJson = json.decode(response);
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to load orders: $error');
    }
  }
}
