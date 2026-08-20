import 'package:signals/signals.dart';
import '../../../shared/network/auth_token_holder.dart';
import '../../../shared/result/result.dart';
import '../../../shared/state/ui_state.dart';
import '../entities/tenant.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginController {
  final AuthRepository _repository;

  LoginController(this._repository);

  final _tenantsState = signal<UiState<List<Tenant>>>(const UiInitial());
  final _loginState = signal<UiState<User>>(const UiInitial());
  final _selectedTenantId = signal<String>('');
  final _email = signal<String>('');
  final _password = signal<String>('');
  final _obscurePassword = signal<bool>(true);

  ReadonlySignal<UiState<List<Tenant>>> get tenantsState => _tenantsState;
  ReadonlySignal<UiState<User>> get state => _loginState;
  ReadonlySignal<String> get selectedTenantId => _selectedTenantId;
  ReadonlySignal<String> get email => _email;
  ReadonlySignal<String> get password => _password;
  ReadonlySignal<bool> get obscurePassword => _obscurePassword;

  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  late final ReadonlySignal<bool> isValid = computed(
    () =>
        emailRegex.hasMatch(_email.value.trim()) &&
        _selectedTenantId.value.isNotEmpty,
  );

  Future<void> loadTenants() async {
    _tenantsState.value = const UiLoading();
    final result = await _repository.getPublicTenants();
    _tenantsState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };

    if (result is Ok) {
      final tenants = result.valueOrNull ?? [];
      if (tenants.isNotEmpty && _selectedTenantId.value.isEmpty) {
        _selectedTenantId.value = tenants.first.id;
      }
    } else {
      // Fallback selection if failed, perhaps clear or keep existing
      _selectedTenantId.value = '';
    }
  }

  void selectTenant(String tenantId) {
    _selectedTenantId.value = tenantId;
  }

  void setEmail(String value) {
    _email.value = value;
  }

  void setPassword(String value) {
    _password.value = value;
  }

  void togglePasswordVisibility() {
    _obscurePassword.value = !_obscurePassword.value;
  }

  Future<void> submitLogin() async {
    _loginState.value = const UiLoading();
    final result = await _repository.login(
      email: _email.value.trim(),
      password: _password.value,
      tenantId: _selectedTenantId.value,
    );
    if (result is Ok<User>) {
      await AuthTokenHolder.instance.saveToken(result.value.token);
      await AuthTokenHolder.instance.saveUser(result.value);
    }
    _loginState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  void resetState() {
    _loginState.value = const UiInitial();
  }

  void dispose() {
    _tenantsState.dispose();
    _loginState.dispose();
    _selectedTenantId.dispose();
    _email.dispose();
    _password.dispose();
    _obscurePassword.dispose();
    isValid.dispose();
  }
}
