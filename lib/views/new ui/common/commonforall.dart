import 'package:flutter/material.dart';

class Commonforall extends StatelessWidget {
  final bool showBack;

  const Commonforall({super.key, this.showBack = false});
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background image
        Image.asset(
          'assets/common/top.png',
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'Background image not found!',
              style: TextStyle(color: Colors.red),
            );
          },
        ),
        // Overlay logo
        Image.asset(
          'assets/common/finact.png',
          width: 150,
          height: 150,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'Logo not found!',
              style: TextStyle(color: Colors.red),
            );
          },
        ),
        if (showBack)
          Positioned(
              top: 72,
              left: 10,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios))),
      ],
    );
  }
}
