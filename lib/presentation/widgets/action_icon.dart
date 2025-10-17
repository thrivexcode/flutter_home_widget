import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ActionIconConfig {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final double size;

  const ActionIconConfig({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(8),
    this.size = 24,
  });
}

class ActionIcon extends StatefulWidget {
  final ActionIconConfig config;

  const ActionIcon({super.key, required this.config});

  @override
  State<ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<ActionIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.reverse();
    await _controller.forward();
    widget.config.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(24.0),
        splashColor: widget.config.iconColor?.withValues(alpha: 0.2),
        child: Padding(
          padding: widget.config.padding,
          child: PhosphorIcon(
            widget.config.icon,
            size: widget.config.size,
            color: widget.config.iconColor,
          ),
        ),
      ),
    );
  }
}
