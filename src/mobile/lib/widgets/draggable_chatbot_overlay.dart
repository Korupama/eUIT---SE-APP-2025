import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/chatbot.dart';

class DraggableChatbotOverlay extends StatefulWidget {
  const DraggableChatbotOverlay({super.key});

  @override
  State<DraggableChatbotOverlay> createState() => _DraggableChatbotOverlayState();
}

class _DraggableChatbotOverlayState extends State<DraggableChatbotOverlay> {
  Offset bubblePosition = const Offset(105, 500); // Initial position
  bool _bubbleClosed = false;
  Offset dragStartOffset = Offset.zero;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final size = MediaQuery.of(context).size;
      // Set initial position to bottom right, above bottom nav
      bubblePosition = Offset(
        size.width - 64 - 20,   // right: 20
        size.height - 64 - 100, // bottom: ~100 (above nav bar)
      );
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bubbleClosed) return const SizedBox.shrink();

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      left: bubblePosition.dx,
      top: bubblePosition.dy,
      child: GestureDetector(
        onPanStart: (details) {
          dragStartOffset = details.globalPosition - bubblePosition;
        },
        onPanUpdate: (details) {
          setState(() {
            bubblePosition = details.globalPosition - dragStartOffset;
          });
        },
        onPanEnd: (details) {
          // Snap to edge
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          
          double targetX = bubblePosition.dx;
          double targetY = bubblePosition.dy;

          // Snap X
          if (bubblePosition.dx < screenWidth / 2) {
            targetX = 10; // Left edge
          } else {
            targetX = screenWidth - 64 - 10; // Right edge
          }

          // Constrain Y to keep within screen
          if (targetY < 50) targetY = 50;
          if (targetY > screenHeight - 150) targetY = screenHeight - 150;

          setState(() {
            bubblePosition = Offset(targetX, targetY);
          });
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatbotScreen(),
                  ),
                );
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.07),
                            Colors.white.withOpacity(0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.smart_toy,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: -7,
              right: -7,
              child: GestureDetector(
                onTap: () => setState(() => _bubbleClosed = true),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
