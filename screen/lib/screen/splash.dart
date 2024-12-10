import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:screen/screen/singup.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to the next screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const NextScreen(), // Replace with your next screen
        ),
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.greenAccent.withOpacity(1.0), // Yellow with full opacity
                  Colors.redAccent.withOpacity(0.5), // Red with 50% opacity
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Positioned image with glassy effect in the center
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glassy effect container
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(20), // Rounded corners
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          width: 220,
                          height: 220,
                          color:
                              Colors.white.withOpacity(0.2), // Semi-transparent
                          alignment: Alignment.center,
                        ),
                      ),
                    ),

                    // Image
                    Image.asset(
                      "assets/images/Asset_1_(2).png",
                      width: 200, // Adjust the width
                      height: 200, // Adjust the height
                    ),
                  ],
                ),

                const SizedBox(height: 20), // Space between the image and text
                const Text(
                  'Room Management system', // Replace with your text
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
