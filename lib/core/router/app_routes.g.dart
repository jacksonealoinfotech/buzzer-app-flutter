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
  $hostDashboardRoute,
  $joinGameRoute,
  $gameLobbyRoute,
  $quizQuestionRoute,
  $quizResultRoute,
];

RouteBase get $splashRoute => GoRouteData.$route(
  path: '/',
  hasOverriddenOnExit: false,
  factory: $SplashRoute._fromState,
);

mixin $SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

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

RouteBase get $hostDashboardRoute => GoRouteData.$route(
  path: '/host-dashboard',
  hasOverriddenOnExit: false,
  factory: $HostDashboardRoute._fromState,
);

mixin $HostDashboardRoute on GoRouteData {
  static HostDashboardRoute _fromState(GoRouterState state) =>
      const HostDashboardRoute();

  @override
  String get location => GoRouteData.$location('/host-dashboard');

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
