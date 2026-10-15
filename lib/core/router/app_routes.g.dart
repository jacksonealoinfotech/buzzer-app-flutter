// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $splashRoute,
  $selectionRoute,
  $loginRoute,
  $signupRoute,
  $securityCheckRoute,
  $hostLoginRoute,
  $hostSignupRoute,
  $gameDetailsRoute,
  $joinGameRoute,
  $gameLobbyRoute,
  $quizQuestionRoute,
  $quizResultRoute,
  $appShellRouteData,
];

RouteBase get $splashRoute => GoRouteData.$route(
  path: '/splash',
  hasOverriddenOnExit: false,
  factory: $SplashRoute._fromState,
);

mixin $SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  @override
  String get location => GoRouteData.$location('/splash');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $selectionRoute => GoRouteData.$route(
  path: '/selection',
  hasOverriddenOnExit: false,
  factory: $SelectionRoute._fromState,
);

mixin $SelectionRoute on GoRouteData {
  static SelectionRoute _fromState(GoRouterState state) =>
      const SelectionRoute();

  @override
  String get location => GoRouteData.$location('/selection');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $loginRoute => GoRouteData.$route(
  path: '/login',
  hasOverriddenOnExit: false,
  factory: $LoginRoute._fromState,
);

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  @override
  String get location => GoRouteData.$location('/login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signupRoute => GoRouteData.$route(
  path: '/signup',
  hasOverriddenOnExit: false,
  factory: $SignupRoute._fromState,
);

mixin $SignupRoute on GoRouteData {
  static SignupRoute _fromState(GoRouterState state) => const SignupRoute();

  @override
  String get location => GoRouteData.$location('/signup');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $securityCheckRoute => GoRouteData.$route(
  path: '/security-check',
  hasOverriddenOnExit: false,
  factory: $SecurityCheckRoute._fromState,
);

mixin $SecurityCheckRoute on GoRouteData {
  static SecurityCheckRoute _fromState(GoRouterState state) =>
      const SecurityCheckRoute();

  @override
  String get location => GoRouteData.$location('/security-check');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $hostLoginRoute => GoRouteData.$route(
  path: '/host-login',
  hasOverriddenOnExit: false,
  factory: $HostLoginRoute._fromState,
);

mixin $HostLoginRoute on GoRouteData {
  static HostLoginRoute _fromState(GoRouterState state) =>
      const HostLoginRoute();

  @override
  String get location => GoRouteData.$location('/host-login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $hostSignupRoute => GoRouteData.$route(
  path: '/host-signup',
  hasOverriddenOnExit: false,
  factory: $HostSignupRoute._fromState,
);

mixin $HostSignupRoute on GoRouteData {
  static HostSignupRoute _fromState(GoRouterState state) =>
      const HostSignupRoute();

  @override
  String get location => GoRouteData.$location('/host-signup');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $gameDetailsRoute => GoRouteData.$route(
  path: '/game-details',
  hasOverriddenOnExit: false,
  factory: $GameDetailsRoute._fromState,
);

mixin $GameDetailsRoute on GoRouteData {
  static GameDetailsRoute _fromState(GoRouterState state) =>
      const GameDetailsRoute();

  @override
  String get location => GoRouteData.$location('/game-details');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $joinGameRoute => GoRouteData.$route(
  path: '/join',
  hasOverriddenOnExit: false,
  factory: $JoinGameRoute._fromState,
);

mixin $JoinGameRoute on GoRouteData {
  static JoinGameRoute _fromState(GoRouterState state) => const JoinGameRoute();

  @override
  String get location => GoRouteData.$location('/join');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $gameLobbyRoute => GoRouteData.$route(
  path: '/gamelobby',
  hasOverriddenOnExit: false,
  factory: $GameLobbyRoute._fromState,
);

mixin $GameLobbyRoute on GoRouteData {
  static GameLobbyRoute _fromState(GoRouterState state) =>
      const GameLobbyRoute();

  @override
  String get location => GoRouteData.$location('/gamelobby');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $quizQuestionRoute => GoRouteData.$route(
  path: '/quizz',
  hasOverriddenOnExit: false,
  factory: $QuizQuestionRoute._fromState,
);

mixin $QuizQuestionRoute on GoRouteData {
  static QuizQuestionRoute _fromState(GoRouterState state) =>
      const QuizQuestionRoute();

  @override
  String get location => GoRouteData.$location('/quizz');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $quizResultRoute => GoRouteData.$route(
  path: '/result',
  hasOverriddenOnExit: false,
  factory: $QuizResultRoute._fromState,
);

mixin $QuizResultRoute on GoRouteData {
  static QuizResultRoute _fromState(GoRouterState state) =>
      const QuizResultRoute();

  @override
  String get location => GoRouteData.$location('/result');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appShellRouteData => StatefulShellRouteData.$route(
  factory: $AppShellRouteDataExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/',
          hasOverriddenOnExit: false,
          factory: $DashboardRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/create-game',
          hasOverriddenOnExit: false,
          factory: $CreateGameRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/settings',
          hasOverriddenOnExit: false,
          factory: $SettingsRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $AppShellRouteDataExtension on AppShellRouteData {
  static AppShellRouteData _fromState(GoRouterState state) =>
      const AppShellRouteData();
}

mixin $DashboardRoute on GoRouteData {
  static DashboardRoute _fromState(GoRouterState state) =>
      const DashboardRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CreateGameRoute on GoRouteData {
  static CreateGameRoute _fromState(GoRouterState state) =>
      const CreateGameRoute();

  @override
  String get location => GoRouteData.$location('/create-game');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
