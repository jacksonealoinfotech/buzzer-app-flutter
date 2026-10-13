import 'package:flutter/material.dart';
import 'package:buzzer_app/core/widgets/animations/shimmer.dart';

// TODO: Uncomment when `cached_network_image` package is enabled in pubspec.yaml:
// import 'package:cached_network_image/cached_network_image.dart';

/// Network image renderer with shimmer loading skeleton and error fallback.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8.0,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    // TODO: Uncomment when `cached_network_image` is enabled:
    // return ClipRRect(
    //   borderRadius: BorderRadius.circular(borderRadius),
    //   child: CachedNetworkImage(
    //     imageUrl: imageUrl,
    //     width: width,
    //     height: height,
    //     fit: fit,
    //     placeholder: (context, url) => AppShimmer.box(width: width ?? 100, height: height ?? 100, borderRadius: borderRadius),
    //     errorWidget: (context, url, error) => _buildErrorWidget(context),
    //   ),
    // );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return AppShimmer.box(
            width: width ?? 100,
            height: height ?? 100,
            borderRadius: borderRadius,
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorWidget(context),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Theme.of(context).colorScheme.outline,
          size: 28,
        ),
      ),
    );
  }
}
