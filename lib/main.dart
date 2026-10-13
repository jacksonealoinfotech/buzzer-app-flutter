import 'package:buzzer_app/app.dart';
import 'package:buzzer_app/bootstrap.dart';
import 'package:buzzer_app/core/config/flavor.dart';

/// Default local run entry point (defaults to dev flavor).
void main() {
  bootstrap(flavor: Flavor.dev, builder: () => const App());
}
