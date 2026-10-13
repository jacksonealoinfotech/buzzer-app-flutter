// ---------------------------------------------------------------------------
// OPTIONAL: Lottie Animation Wrapper
// ---------------------------------------------------------------------------
// TODO: Uncomment when `lottie` package is added to pubspec.yaml:
// import 'package:flutter/widgets.dart';
// import 'package:lottie/lottie.dart';
//
// class AppLottie extends StatelessWidget {
//   const AppLottie({
//     required this.assetPath,
//     super.key,
//     this.width,
//     this.height,
//     this.repeat = true,
//   });
//
//   final String assetPath;
//   final double? width;
//   final double? height;
//   final bool repeat;
//
//   @override
//   Widget build(BuildContext context) {
//     return Lottie.asset(assetPath, width: width, height: height, repeat: repeat);
//   }
// }

// ---------------------------------------------------------------------------
// OPTIONAL: Rive Animation Wrapper
// ---------------------------------------------------------------------------
// TODO: Uncomment when `rive` package is added to pubspec.yaml:
// import 'package:rive/rive.dart';
//
// class AppRive extends StatelessWidget {
//   const AppRive({
//     required this.assetPath,
//     super.key,
//     this.artboard,
//     this.animation,
//   });
//
//   final String assetPath;
//   final String? artboard;
//   final String? animation;
//
//   @override
//   Widget build(BuildContext context) {
//     return RiveAnimation.asset(assetPath, artboard: artboard, animations: animation != null ? [animation!] : const []);
//   }
// }

// ---------------------------------------------------------------------------
// OPTIONAL: OpenContainer Transform Wrapper (Material Motion)
// ---------------------------------------------------------------------------
// TODO: Uncomment when `animations` package is added to pubspec.yaml:
// import 'package:animations/animations.dart';
//
// class AppOpenContainer extends StatelessWidget {
//   const AppOpenContainer({
//     required this.closedBuilder,
//     required this.openBuilder,
//     super.key,
//   });
//
//   final CloseContainerBuilder closedBuilder;
//   final OpenContainerBuilder openBuilder;
//
//   @override
//   Widget build(BuildContext context) {
//     return OpenContainer(
//       closedBuilder: closedBuilder,
//       openBuilder: openBuilder,
//       transitionType: ContainerTransitionType.fadeThrough,
//     );
//   }
// }
