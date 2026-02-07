import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

class TripCardShimmer extends StatelessWidget {
  const TripCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image shimmer
            ShimmerLoader(
              width: double.infinity,
              height: 180,
              borderRadius: 12,
            ),
            const SizedBox(height: 20),
            // Title shimmer
            ShimmerLoader(
              width: 200,
              height: 20,
              borderRadius: 4,
            ),
            const SizedBox(height: 16),
            // Date shimmer
            ShimmerLoader(
              width: 150,
              height: 16,
              borderRadius: 4,
            ),
            const SizedBox(height: 16),
            // Progress bar shimmer
            ShimmerLoader(
              width: double.infinity,
              height: 8,
              borderRadius: 4,
            ),
            const SizedBox(height: 20),
            // Button shimmer
            Row(
              children: [
                Expanded(
                  child: ShimmerLoader(
                    width: double.infinity,
                    height: 48,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShimmerLoader(
                    width: double.infinity,
                    height: 48,
                    borderRadius: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}