import 'package:flutter/material.dart';
import '../../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1B263B), // Dark background
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                order.picture,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey[400]),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Order Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order.buyer,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // White text
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.company,
                    style: const TextStyle(
                      color: Colors.white, // White text
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price: \$${order.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white, // White text
                      fontSize: 14,
                    ),
                  ),
                  if (order.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: order.tags
                          .map((tag) => Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(4),
                                backgroundColor: Colors.grey[700],
                              ))
                          .toList(),
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        order.isActive ? Icons.check_circle : Icons.cancel,
                        color: order.isActive ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: order.isActive ? Colors.green : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ORDERED':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'SHIPPED':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.green;
      case 'RETURNED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
