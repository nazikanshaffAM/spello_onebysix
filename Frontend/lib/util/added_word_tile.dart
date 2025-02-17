import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AddedWordTile extends StatelessWidget {
  final String taskName;
  final Function(BuildContext)? deleteFunction;

  const AddedWordTile({
    super.key,
    required this.taskName,
    required this.deleteFunction,
  });

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
        top: screenHeight * 0.03,
        left: screenWidth * 0.06,
        right: screenWidth * 0.06,
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red,
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  taskName,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // Responsive font size
                    color: Color(0xFF485669), // Ensuring visibility
                    fontFamily: "Fredoka One",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
