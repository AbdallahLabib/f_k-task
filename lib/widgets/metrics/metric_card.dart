import 'package:flutter/material.dart';

class MetricCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: Card(
          elevation: _isHovered ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()
                        ..scale(_isHovered ? 1.1 : 1.0),
                      child: Icon(widget.icon, color: widget.color, size: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: widget.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: _isHovered ? 26 : 24,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                  child: Text(widget.value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
