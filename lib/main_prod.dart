import 'package:buzzer_app/app.dart';
import 'package:buzzer_app/bootstrap.dart';
import 'package:buzzer_app/core/config/flavor.dart';

void main() {
  bootstrap(flavor: Flavor.prod, builder: () => const App());
}
