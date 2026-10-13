import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buzzer_app/core/services/connectivity/connectivity_cubit.dart';

/// Animated offline banner sliding into view at the top of the screen when device loses internet.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, bool>(
      builder: (context, isConnected) {
        return Stack(
          children: [
            child,
            // AnimatedPositioned(
            //   duration: const Duration(milliseconds: 300),
            //   curve: Curves.easeInOut,
            //   top: isConnected ? -50 : 0,
            //   left: 0,
            //   right: 0,
            //   child: Material(
            //     color: Colors.red.shade900,
            //     elevation: 4,
            //     child: SafeArea(
            //       bottom: false,
            //       child: Container(
            //         height: 36,
            //         alignment: Alignment.center,
            //         child: const Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
            //             SizedBox(width: 8),
            //             Text(
            //               'No Internet Connection • Offline Mode Active',
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 12,
            //                 fontWeight: FontWeight.w600,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
