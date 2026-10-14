import 'package:buzzer_app/features/hostFlow/host_dashboard/presenation/screen/host_dashboard_screen.dart';
import 'package:buzzer_app/features/playerFlow/quiz_question/presenation/screen/quiz_question_screen.dart';
import 'package:buzzer_app/features/playerFlow/quiz_result/presenation/screen/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:buzzer_app/features/onboarding/login/presenation/screen/login_screen.dart';
import 'package:buzzer_app/features/onboarding/selection/presenation/screen/selection_screen.dart';
import 'package:buzzer_app/features/onboarding/signup/presenation/screen/signup_screen.dart';
import 'package:buzzer_app/features/onboarding/splash/presenation/screen/splash_screen.dart';
import 'package:buzzer_app/features/playerFlow/game_lobby/presenation/screen/game_lobby_screen.dart';
import 'package:buzzer_app/features/playerFlow/join_game/presenation/screen/join_game_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:buzzer_app/core/responsive/adaptive_scaffold.dart';
import 'package:buzzer_app/core/security/security_check_screen.dart';
part 'app_routes.g.dart';

// dart run build_runner build -d

@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => SplashScreen(
    onFinished: () {
      const SelectionRoute().go(context);
    },
  );
}

@TypedGoRoute<SelectionRoute>(path: '/selection')
class SelectionRoute extends GoRouteData with $SelectionRoute {
  const SelectionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SelectionScreen(
    onHost: () {
      const LoginRoute().push<void>(context);
    },
    onPlayer: () {
      const LoginRoute().push<void>(context);
    },
  );
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => LoginScreen(
    onCreateAccount: () {
      const SignupRoute().push<void>(context);
    },
  );
}

@TypedGoRoute<SignupRoute>(path: '/signup')
class SignupRoute extends GoRouteData with $SignupRoute {
  const SignupRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SignUpScreen(
    onSignIn: () {
      const JoinGameRoute().go(context);
    },
  );
}

@TypedGoRoute<SecurityCheckRoute>(path: '/security-check')
class SecurityCheckRoute extends GoRouteData with $SecurityCheckRoute {
  const SecurityCheckRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SecurityCheckScreen();
}

//Host flow screens
@TypedGoRoute<HostDashboardRoute>(path: '/host-dashboard')
class HostDashboardRoute extends GoRouteData with $HostDashboardRoute {
  const HostDashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const HostDashboardScreen(
        hostName: 'name',
        games: [
          HostGame(
            id: 'ididididi',
            title: 'game',
            mode: GameMode.quiz,
            status: GameStatus.completed,
            questionCount: 30,
            players: 30,
            maxPlayers: 30,
          ),
        ],
      );
}

//Player flow screeens
@TypedGoRoute<JoinGameRoute>(path: '/join')
class JoinGameRoute extends GoRouteData with $JoinGameRoute {
  const JoinGameRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const JoinGameScreen();
}

@TypedGoRoute<GameLobbyRoute>(path: '/gamelobby')
class GameLobbyRoute extends GoRouteData with $GameLobbyRoute {
  const GameLobbyRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => GameLobbyScreen(
    gameTitle: 'game',
    participantCount: 10,
    maxParticipants: 25,
    gameMode: 'game mode',
    questionDurationSeconds: 30,
    questionCount: 50,
    onCountdownFinished: () {
      const QuizQuestionRoute().push<void>(context);
    },
  );
}

@TypedGoRoute<QuizQuestionRoute>(path: '/quizz')
class QuizQuestionRoute extends GoRouteData with $QuizQuestionRoute {
  const QuizQuestionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => QuizQuestionScreen(
    gameTitle: 'title',
    questions: [
      QuizQuestion(
        text: 'what is your name?',
        options: ['jackson', 'jacky', 'john', 'michale'],
      ),
    ],
    onFinished: (value) {
      const QuizResultRoute().push<void>(context);
    },
  );
}

@TypedGoRoute<QuizResultRoute>(path: '/result')
class QuizResultRoute extends GoRouteData with $QuizResultRoute {
  const QuizResultRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => QuizResultScreen(
    correctAnswers: 10,
    totalQuestions: 30,
    rank: 2,
    totalPlayers: 20,
    onBackHome: () {
      const JoinGameRoute().go(context);
    },
  );
}

// @TypedStatefulShellRoute<AppShellRouteData>(
//   branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
//     TypedStatefulShellBranch<HomeBranchData>(routes: <TypedRoute<RouteData>>[]),
//     TypedStatefulShellBranch<ExploreBranchData>(
//       routes: <TypedRoute<RouteData>>[TypedRoute()],
//     ),
//     TypedStatefulShellBranch<SettingsBranchData>(
//       routes: <TypedRoute<RouteData>>[TypedRoute()],
//     ),
//   ],
// )
class AppShellRouteData extends StatefulShellRouteData {
  const AppShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return AdaptiveNavigationScaffold(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      destinations: const [
        AdaptiveNavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Showcase',
        ),
        AdaptiveNavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore_rounded),
          label: 'Explore',
        ),
        AdaptiveNavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
      body: navigationShell,
    );
  }
}

// class HomeBranchData extends StatefulShellBranchData {
//   const HomeBranchData();
// }

// class ExploreBranchData extends StatefulShellBranchData {
//   const ExploreBranchData();
// }

// class SettingsBranchData extends StatefulShellBranchData {
//   const SettingsBranchData();
// }
