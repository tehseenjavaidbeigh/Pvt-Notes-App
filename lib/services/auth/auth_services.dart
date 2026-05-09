import 'package:pvtnotes/services/auth/auth_user.dart';
import 'package:pvtnotes/services/auth/auth_provider.dart';
import 'package:pvtnotes/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> login({required String email, required String password}) =>
      provider.login(email: email, password: password);

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) => provider.register(email: email, password: password);

  @override
  Future<void> logout() => provider.logout();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() {
    return provider.initialize();
  }
}
