import 'package:flutter/material.dart';

class ControlPanelTiles extends StatefulWidget {
  const ControlPanelTiles(
      {super.key, required this.tileName, this.isLocked = false});

  final String tileName;
  final bool isLocked;

  @override
  State<ControlPanelTiles> createState() => _ControlPanelTilesState();
}

class _ControlPanelTilesState extends State<ControlPanelTiles> {
  bool _isPressed = false; // Tracks button pressed state

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          color: widget.isLocked
              ? Colors.grey[300] // Disabled look when locked
              : _isPressed
                  ? const Color(0xFFFFC000)
                  : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.isLocked
                  ? Colors.grey // No shadow when locked
                  : _isPressed
                      ? const Color(0xFFD29338)
                      : const Color(0xFF858D9A),
              offset: const Offset(0, 4),
              blurRadius: 5,
            )
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: widget.isLocked
              ? null // Disable button when locked
              : () {
                  setState(() {
                    _isPressed = !_isPressed; // Toggle pressed state
                  });
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    widget.tileName,
                    style: TextStyle(
                      color: const Color(0xFF4C5679),
                      fontSize: 16,
                      fontFamily: 'Fredoka One',
                    ),
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.isLocked
                      ? Colors.grey // Greyed out when locked
                      : _isPressed
                          ? const Color(0xFF4C5679)
                          : const Color(0xFFE8E8E8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isLocked
                      ? Icons.lock // Show lock icon when locked
                      : _isPressed
                          ? Icons.check
                          : Icons.add,
                  color: widget.isLocked
                      ? Colors.white // White lock icon when locked
                      : _isPressed
                          ? const Color(0xFFFFC000)
                          : const Color(0xFF4C5679),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
