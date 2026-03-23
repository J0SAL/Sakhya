import 'package:flutter/material.dart';

class NotificationOverlay {
  static void show(BuildContext context, String message, {bool isError = false, bool isSuccess = false}) {
    Color bgColor = Colors.orange;
    if (isError) bgColor = Colors.red;
    if (isSuccess) bgColor = Colors.green;

    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWidget(message: message, bgColor: bgColor, onClose: () {
        overlayEntry.remove();
      }),
    );

    overlayState.insert(overlayEntry);
  }
}

class _NotificationWidget extends StatefulWidget {
  final String message;
  final Color bgColor;
  final VoidCallback onClose;

  const _NotificationWidget({required this.message, required this.bgColor, required this.onClose});

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _offsetAnim = Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        await _controller.reverse();
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnim,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text(widget.message, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
