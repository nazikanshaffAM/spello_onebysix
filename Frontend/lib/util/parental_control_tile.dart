import 'package:flutter/material.dart';

class ControlPanelTiles extends StatefulWidget {
  const ControlPanelTiles({
    super.key, 
    required this.tileName, 
    this.isLocked = false,
    this.isSelected = false,  // Selection state passed from parent
    this.onSelectionChanged,  // Callback to notify parent of selection changes
  });

  final String tileName;
  final bool isLocked;
  final bool isSelected;
  final Function(bool)? onSelectionChanged;  // Add callback for selection changes

  @override
  State<ControlPanelTiles> createState() => _ControlPanelTilesState();
}

class _ControlPanelTilesState extends State<ControlPanelTiles> {
  late bool _isPressed; // Tracks button pressed state
  
  @override
  void initState() {
    super.initState();
    _isPressed = widget.isSelected; // Initialize from isSelected prop
    print("ControlPanelTiles initState: ${widget.tileName} - isSelected: ${widget.isSelected}, isLocked: ${widget.isLocked}");
  }
  
  @override
  void didUpdateWidget(ControlPanelTiles oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update local state if the prop changed from parent
    if (widget.isSelected != oldWidget.isSelected) {
      setState(() {
        _isPressed = widget.isSelected;
      });
      print("ControlPanelTiles didUpdateWidget: ${widget.tileName} - isSelected changed to ${widget.isSelected}");
    }
  }

  void _handlePress() {
    // Only toggle if not locked or already selected
    if (!widget.isLocked || _isPressed) {
      setState(() {
        _isPressed = !_isPressed; // Toggle pressed state
      });
      
      // Notify parent component about the change
      if (widget.onSelectionChanged != null) {
        widget.onSelectionChanged!(_isPressed);
        print("ControlPanelTiles: Notified parent that ${widget.tileName} is now $_isPressed");
      }
    } else {
      print("ControlPanelTiles: ${widget.tileName} is locked and not selected, ignoring press");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Allow button to be pressed if it's not locked or if it's already selected
    final bool isButtonEnabled = !widget.isLocked || _isPressed;
    
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          color: !isButtonEnabled
              ? Colors.grey[300] // Disabled look when locked
              : _isPressed
                  ? const Color(0xFFFFC000)
                  : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: !isButtonEnabled
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
          onPressed: isButtonEnabled ? _handlePress : null,
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
                  color: !isButtonEnabled
                      ? Colors.grey // Greyed out when locked
                      : _isPressed
                          ? const Color(0xFF4C5679)
                          : const Color(0xFFE8E8E8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  !isButtonEnabled && !_isPressed
                      ? Icons.lock // Show lock icon when locked and not selected
                      : _isPressed
                          ? Icons.check
                          : Icons.add,
                  color: !isButtonEnabled && !_isPressed
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