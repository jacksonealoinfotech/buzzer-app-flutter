/// Sealed hierarchy of user session states.
sealed class SessionState {
  const SessionState();
}

/// No active user session.
final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

/// Active user session within valid timeout parameters.
final class SessionActive extends SessionState {
  const SessionActive({required this.lastActivity});
  final DateTime lastActivity;
}

/// Session locked due to background idle duration or inactivity.
final class SessionLocked extends SessionState {
  const SessionLocked({required this.reason});
  final String reason;
}

/// Session expired and requires re-authentication.
final class SessionExpired extends SessionState {
  const SessionExpired({
    this.message = 'Session has expired due to inactivity.',
  });
  final String message;
}
