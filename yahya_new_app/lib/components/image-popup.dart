import 'package:flutter/material.dart';

class ImagePopup extends StatelessWidget {
  final String imageUrl;
  const ImagePopup({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(), // يغلق النافذة عند الضغط
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(0.9),
          ),
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                  size: 100, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
