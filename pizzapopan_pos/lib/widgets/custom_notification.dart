import 'package:flutter/material.dart';

void showCustomNotification(BuildContext context, String message, {bool isError = false}) {
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.5 - 50, // Centered
      left: MediaQuery.of(context).size.width * 0.25,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            overlayEntry.remove();
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isError ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context)!.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}