import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Qibla Compass", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: FlutterQiblah.androidDeviceSensorSupport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFbf8a2b)));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.data == true) {
            return const QiblaCompass();
          } else {
            return const Center(child: Text("Your device does not have a compass sensor!"));
          }
        },
      ),
    );
  }
}

class QiblaCompass extends StatelessWidget {
  const QiblaCompass({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        // --- SAFE CHECK ---
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFbf8a2b)));
        }

        final qiblahDirection = snapshot.data!;

        // 1. Calculate Rotation Angle for the Needle (Standard Compass Math)
        final double angle = ((qiblahDirection.qiblah) * (pi / 180) * -1);

        // 2. STRICT RANGE LOGIC: 62° to 66° ONLY
        // We look at the actual compass heading (direction)
        double currentHeading = qiblahDirection.direction;

        // The circle lights up ONLY if we are between 62 and 66
        bool isAligned = currentHeading >= 62 && currentHeading <= 66;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Compass Stack ---
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        // Ring turns Gold if aligned!
                          color: isAligned ? const Color(0xFFbf8a2b) : Colors.grey.shade300,
                          width: 3
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: angle,
                    child: Icon(
                      Icons.navigation,
                      size: 200,
                      // Needle turns Gold if aligned!
                      color: isAligned ? const Color(0xFFbf8a2b) : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- Text Displays ---
              Text(
                "${currentHeading.toInt()}°",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  // Text turns Gold too!
                  color: isAligned ? const Color(0xFFbf8a2b) : Colors.black,
                ),
              ),
              const Text(
                "Target Zone: 64°",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // --- THE INDICATOR CIRCLE ---
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Logic: Gold if aligned, Black if not
                  color: isAligned ? const Color(0xFFbf8a2b) : Colors.black,
                  boxShadow: isAligned ? [
                    BoxShadow(
                        color: const Color(0xFFbf8a2b).withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5
                    )
                  ] : [],
                ),
                child: Icon(
                  isAligned ? Icons.check : Icons.close,
                  color: isAligned ? Colors.white : Colors.grey,
                  size: 35,
                ),
              ),

              const SizedBox(height: 10),
              // Helper Text
              Text(
                isAligned ? "Perfect!" : "Rotate Phone",
                style: TextStyle(
                    color: isAligned ? const Color(0xFFbf8a2b) : Colors.grey,
                    fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        );
      },
    );
  }
}