import 'package:buzzer_app/core/di/injection.dart';
import 'package:buzzer_app/core/security/token_manager.dart';
import 'package:buzzer_app/features/hostFlow/create_game/presenation/screen/create_game_screen.dart';
import 'package:buzzer_app/features/hostFlow/game_details/presenation/screen/game_details_screen.dart';
import 'package:buzzer_app/features/hostFlow/host_dashboard/presenation/screen/host_dashboard_screen.dart';
import 'package:buzzer_app/features/hostFlow/host_login/presenation/bloc/host_login_bloc.dart';
import 'package:buzzer_app/features/hostFlow/host_login/presenation/screen/host_login_screen.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/presenation/bloc/host_signup_bloc.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/presenation/screen/host_signup_screen.dart';
import 'package:buzzer_app/features/hostFlow/settings/presenation/screen/settings_screen.dart';
import 'package:buzzer_app/features/playerFlow/quiz_question/presenation/screen/quiz_question_screen.dart';
import 'package:buzzer_app/features/playerFlow/quiz_result/presenation/screen/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:buzzer_app/features/playerFlow/login/presenation/screen/login_screen.dart';
import 'package:buzzer_app/features/onboarding/selection/presenation/screen/selection_screen.dart';
import 'package:buzzer_app/features/playerFlow/signup/presenation/screen/signup_screen.dart';
import 'package:buzzer_app/features/onboarding/splash/presenation/screen/splash_screen.dart';
import 'package:buzzer_app/features/playerFlow/game_lobby/presenation/screen/game_lobby_screen.dart';
import 'package:buzzer_app/features/playerFlow/join_game/presenation/screen/join_game_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:buzzer_app/core/responsive/adaptive_scaffold.dart';
import 'package:buzzer_app/core/security/security_check_screen.dart';
part 'app_routes.g.dart';

// dart run build_runner build -d

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => SplashScreen(
    onFinished: () {
      if (getIt<TokenManager>().isAuthenticated) {
        const DashboardRoute().go(context);
      } else {
        const SelectionRoute().go(context);
      }
    },
  );
}

@TypedGoRoute<SelectionRoute>(path: '/selection')
class SelectionRoute extends GoRouteData with $SelectionRoute {
  const SelectionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SelectionScreen(
    onHost: () {
      const HostLoginRoute().push<void>(context);
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
@TypedGoRoute<HostLoginRoute>(path: '/host-login')
class HostLoginRoute extends GoRouteData with $HostLoginRoute {
  const HostLoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BlocProvider<HostLoginBloc>(
        create: (_) => getIt<HostLoginBloc>(),
        child: HostLoginScreen(
          onCreateAccount: () {
            const HostSignupRoute().go(context);
          },
        ),
      );
}

@TypedGoRoute<HostSignupRoute>(path: '/host-signup')
class HostSignupRoute extends GoRouteData with $HostSignupRoute {
  const HostSignupRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BlocProvider<HostSignupBloc>(
        create: (_) => getIt<HostSignupBloc>(),
        child: const HostSignupScreen(),
      );
}

@TypedGoRoute<GameDetailsRoute>(path: '/game-details')
class GameDetailsRoute extends GoRouteData with $GameDetailsRoute {
  const GameDetailsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => GameDetailsScreen(
    game: GameDetails(
      id: 'id',
      code: 'code',
      title: 'title',
      description: 'description',
      mode: GameMode.quiz,
      status: GameStatus.completed,
      startsAt: DateTime.now(),
      timeZone: '',
      questionDurationSeconds: 30,
      openRegistration: false,
      players: 10,
      maxPlayers: 30,
    ),
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

@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<DashboardBranchData>(
      routes: <TypedRoute<RouteData>>[TypedGoRoute<DashboardRoute>(path: '/')],
    ),
    TypedStatefulShellBranch<CreateGameBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<CreateGameRoute>(path: '/create-game'),
      ],
    ),
    TypedStatefulShellBranch<SettingsBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<SettingsRoute>(path: '/settings'),
      ],
    ),
  ],
)
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
          label: 'Dashboard',
        ),
        AdaptiveNavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore_rounded),
          label: 'create',
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

class DashboardBranchData extends StatefulShellBranchData {
  const DashboardBranchData();
}

class CreateGameBranchData extends StatefulShellBranchData {
  const CreateGameBranchData();
}

class SettingsBranchData extends StatefulShellBranchData {
  const SettingsBranchData();
}

class DashboardRoute extends GoRouteData with $DashboardRoute {
  const DashboardRoute();

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

class CreateGameRoute extends GoRouteData with $CreateGameRoute {
  const CreateGameRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => CreateGameScreen(
    onPickPdf: () async {
      return null;
    },
  );
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsScreen(hostName: 'name', email: 'email');
}
