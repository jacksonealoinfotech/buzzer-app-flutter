# Features Directory (Clean Architecture Guide)

This directory hosts all business vertical features. Every feature follows a **Feature-First Clean Architecture** design.

> **CRITICAL ARCHITECTURAL RULE:**
> `core/` must **never** depend on `features/`. Features depend inward on `core/` and other shared contracts, never the reverse.

---

## Expected Folder Structure per Feature

When implementing a new feature (e.g. `authentication`, `products`, `orders`), replicate the following layer structure:

```
features/
 └─ <feature_name>/
     ├─ data/
     │   ├─ datasources/
     │   │   ├─ <feature>_remote_data_source.dart   (Dio API calls using safeCall)
     │   │   └─ <feature>_local_data_source.dart    (sqflite DAO / cache calls)
     │   ├─ models/
     │   │   ├─ <entity>_dto.dart                   (Freezed / json_serializable DTOs)
     │   │   └─ <entity>_dto.freezed.dart
     │   └─ repositories/
     │       └─ <feature>_repository_impl.dart      (Implements domain repository contract)
     │
     ├─ domain/
     │   ├─ entities/
     │   │   └─ <entity>.dart                       (Pure immutable domain entity)
     │   ├─ repositories/
     │   │   └─ <feature>_repository.dart           (Abstract interface class returning Result<T>)
     │   └─ usecases/
     │       ├─ get_<entity>_usecase.dart           (Extends UseCase<Type, Params>)
     │       └─ watch_<entity>_usecase.dart         (Extends StreamUseCase<Type, Params>)
     │
     └─ presentation/
         ├─ controllers/ / blocs/
         │   ├─ <feature>_cubit.dart                (or Bloc if complex event streams needed)
         │   └─ <feature>_state.dart                (Freezed sealed state: initial/loading/success/failure)
         ├─ routes/
         │   └─ <feature>_routes.dart               (@TypedGoRoute route definitions)
         └─ views/
             ├─ <feature>_screen.dart               (Consumes BlocStateBuilder / AsyncStateView)
             └─ widgets/                            (Sub-components local to this screen)
```

---

## 5-Step Guide to Adding a New Feature

### Step 1: Define Domain Entity & Repository Contract
Create pure entities and repository interface in `domain/`:
```dart
// domain/entities/user_profile.dart
class UserProfile {
  const UserProfile({required this.id, required this.email, required this.displayName});
  final String id;
  final String email;
  final String displayName;
}

// domain/repositories/user_repository.dart
abstract interface class UserRepository {
  Future<Result<UserProfile>> getUserProfile();
}
```

### Step 2: Implement Use Case
```dart
// domain/usecases/get_user_profile_usecase.dart
@injectable
class GetUserProfileUseCase implements UseCase<UserProfile, NoParams> {
  const GetUserProfileUseCase(this._repository);
  final UserRepository _repository;

  @override
  Future<Result<UserProfile>> call(NoParams params) {
    return _repository.getUserProfile();
  }
}
```

### Step 3: Implement Data Layer (DTOs & Repository)
```dart
// data/repositories/user_repository_impl.dart
@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remoteDataSource);
  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<Result<UserProfile>> getUserProfile() async {
    return safeCall(() async {
      final dto = await _remoteDataSource.fetchProfile();
      return dto.toDomain();
    });
  }
}
```

### Step 4: Create Presentation Cubit/Bloc
```dart
// presentation/controllers/user_cubit.dart
@injectable
class UserCubit extends Cubit<UserState> {
  UserCubit(this._getUserProfileUseCase) : super(const UserState.initial());
  final GetUserProfileUseCase _getUserProfileUseCase;

  Future<void> loadProfile() async {
    emit(const UserState.loading());
    final result = await _getUserProfileUseCase(const NoParams());
    switch (result) {
      case Success(:final data):
        emit(UserState.loaded(data));
      case FailureResult(:final failure):
        emit(UserState.error(failure.message));
    }
  }
}
```

### Step 5: Render in UI with `AsyncStateView`
```dart
// presentation/views/user_screen.dart
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return AsyncStateView(
          isLoading: state.isLoading,
          result: state.result,
          dataBuilder: (context, profile) => Text('Welcome, ${profile.displayName}'),
        );
      },
    );
  }
}
```
