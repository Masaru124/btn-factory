enum AuthStatus { loading, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.accessToken,
    this.userName,
    this.userEmail,
    this.userRole,
    this.userDepartment,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? accessToken;
  final String? userName;
  final String? userEmail;
  final String? userRole;
  final String? userDepartment;
  final String? errorMessage;

  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);

  factory AuthState.unauthenticated({String? errorMessage}) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: errorMessage,
    );
  }

  factory AuthState.authenticated({
    required String accessToken,
    required String userName,
    required String userEmail,
    required String userRole,
    required String userDepartment,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      accessToken: accessToken,
      userName: userName,
      userEmail: userEmail,
      userRole: userRole,
      userDepartment: userDepartment,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    String? accessToken,
    String? userName,
    String? userEmail,
    String? userRole,
    String? userDepartment,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userRole: userRole ?? this.userRole,
      userDepartment: userDepartment ?? this.userDepartment,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
