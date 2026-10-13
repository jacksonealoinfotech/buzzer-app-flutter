import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buzzer_app/core/config/env.dart';
import 'package:buzzer_app/core/config/flavor.dart';
import 'package:buzzer_app/core/di/injection.dart';
import 'package:buzzer_app/core/widgets/buttons/app_button.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockHydratedStorage extends Mock implements Storage;

void main() {
  late Storage storage;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    storage = MockHydratedStorage();
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    when(() => storage.read(any())).thenReturn(null);
    HydratedBloc.storage = storage;

    AppEnv.initialize(appFlavor: Flavor.dev);
    await configureDependencies(Flavor.dev.name);
  });

  tearDown(() async {
    await resetDependencies();
  });

  testWidgets('ShowcaseScreen renders cleanly with all components', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // await tester.pumpWidget(
    //   MultiBlocProvider(
    //     providers: [
    //       BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
    //       BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
    //     ],
    //     child: const MaterialApp(
    //       home: ShowcaseScreen(),
    //     ),
    //   ),
    // );

    // Pump frames
    // await tester.pump();
    // await tester.pump(const Duration(milliseconds: 400));

    // Verify AppBar header
    expect(find.text('Flutter Clean Architecture'), findsOneWidget);

    // Verify Hero card
    expect(find.text('Production-Grade Base Template'), findsOneWidget);

    // Verify AppButton presence
    expect(find.text('Primary Button'), findsOneWidget);

    // Tap Primary Button
    await tester.tap(find.text('Primary Button'));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify AppButton widget presence
    expect(find.byType(AppButton), findsWidgets);
  });
}
