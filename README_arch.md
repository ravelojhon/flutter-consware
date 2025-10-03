# Arquitectura de la Aplicación Flutter

## Estructura de Carpetas

Este proyecto sigue los principios de **Clean Architecture** para mantener un código organizado, escalable y fácil de mantener.

### 📁 Estructura de Directorios

```
lib/src/
├── core/                    # Funcionalidades centrales y compartidas
├── data/                    # Capa de datos
│   ├── local/              # Almacenamiento local (SQLite, SharedPreferences, etc.)
│   └── repositories/       # Implementaciones de repositorios
├── domain/                 # Capa de dominio (lógica de negocio)
│   ├── entities/           # Modelos de dominio
│   ├── usecases/           # Casos de uso
│   └── repositories/       # Contratos de repositorios
└── presentation/           # Capa de presentación
    ├── providers/          # Gestión de estado (Provider, Riverpod, etc.)
    ├── screens/            # Pantallas de la aplicación
    └── widgets/            # Componentes reutilizables
```

## 🎯 Responsabilidades de Cada Capa

### **Core**
- **Propósito**: Funcionalidades centrales compartidas en toda la aplicación
- **Contenido**:
  - Constantes globales
  - Utilidades comunes
  - Configuraciones
  - Errores personalizados
  - Extensiones
  - Validadores

**Ejemplo:**
```dart
// lib/src/core/constants/app_constants.dart
class AppConstants {
  static const String apiBaseUrl = 'https://api.ejemplo.com';
  static const int timeoutDuration = 30;
}

// lib/src/core/errors/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}
```

### **Domain**
- **Propósito**: Contiene la lógica de negocio pura, independiente de frameworks
- **Contenido**:
  - **Entities**: Modelos de dominio que representan conceptos del negocio
  - **UseCases**: Casos de uso específicos que encapsulan la lógica de negocio
  - **Repositories**: Contratos/interfaces que definen cómo acceder a los datos

**Ejemplo:**
```dart
// lib/src/domain/entities/user.dart
class User {
  final String id;
  final String name;
  final String email;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
  });
}

// lib/src/domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<User> getUserById(String id);
  Future<List<User>> getAllUsers();
  Future<void> saveUser(User user);
}

// lib/src/domain/usecases/get_user.dart
class GetUser {
  final UserRepository repository;
  
  GetUser(this.repository);
  
  Future<Either<Failure, User>> call(String id) async {
    try {
      final user = await repository.getUserById(id);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

### **Data**
- **Propósito**: Implementa el acceso a datos y fuentes externas
- **Contenido**:
  - **Local**: Implementaciones de almacenamiento local
  - **Repositories**: Implementaciones concretas de los contratos del dominio

**Ejemplo:**
```dart
// lib/src/data/local/database_helper.dart
class DatabaseHelper {
  static Database? _database;
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    // Configuración de SQLite
  }
}

// lib/src/data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final DatabaseHelper _databaseHelper;
  
  UserRepositoryImpl(this._databaseHelper);
  
  @override
  Future<User> getUserById(String id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    throw Exception('User not found');
  }
}
```

### **Presentation**
- **Propósito**: Maneja la interfaz de usuario y la gestión de estado
- **Contenido**:
  - **Providers**: Gestión de estado y lógica de presentación
  - **Screens**: Pantallas de la aplicación
  - **Widgets**: Componentes reutilizables de UI

**Ejemplo:**
```dart
// lib/src/presentation/providers/user_provider.dart
class UserProvider extends ChangeNotifier {
  final GetUser _getUser;
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  UserProvider(this._getUser);
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await _getUser(id);
    
    result.fold(
      (failure) => _error = failure.message,
      (user) => _user = user,
    );
    
    _isLoading = false;
    notifyListeners();
  }
}

// lib/src/presentation/screens/user_screen.dart
class UserScreen extends StatelessWidget {
  final String userId;
  
  const UserScreen({Key? key, required this.userId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(
        GetUser(Provider.of<UserRepository>(context, listen: false))
      )..loadUser(userId),
      child: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const CircularProgressIndicator();
          }
          
          if (provider.error != null) {
            return Text('Error: ${provider.error}');
          }
          
          return UserWidget(user: provider.user!);
        },
      ),
    );
  }
}
```

## 🔄 Flujo de Datos Completo

### Ejemplo: Obtener Usuario por ID

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI/Screen     │    │    Provider     │    │    UseCase      │
│                 │    │                 │    │                 │
│ UserScreen      │───▶│ UserProvider    │───▶│ GetUser         │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Local DB      │◀───│  Repository     │◀───│   Repository    │
│                 │    │                 │    │   Interface     │
│ SQLite/Shared   │    │ UserRepository  │    │                 │
│                 │    │ Impl            │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 1. **UI → Provider**
```dart
// El usuario toca un botón en UserScreen
onPressed: () => context.read<UserProvider>().loadUser(userId)
```

### 2. **Provider → UseCase**
```dart
// UserProvider llama al caso de uso
final result = await _getUser(id);
```

### 3. **UseCase → Repository**
```dart
// GetUser llama al repositorio
final user = await repository.getUserById(id);
```

### 4. **Repository → Local DB**
```dart
// UserRepositoryImpl consulta la base de datos local
final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
```

### 5. **Respuesta en reversa**
```
Local DB → Repository → UseCase → Provider → UI
```

## 🎯 Beneficios de esta Arquitectura

1. **Separación de Responsabilidades**: Cada capa tiene un propósito específico
2. **Testabilidad**: Fácil de probar cada componente por separado
3. **Mantenibilidad**: Cambios en una capa no afectan las otras
4. **Escalabilidad**: Fácil agregar nuevas funcionalidades
5. **Independencia**: La lógica de negocio no depende de frameworks externos
6. **Reutilización**: Los casos de uso pueden reutilizarse en diferentes interfaces

## 📝 Convenciones de Naming

- **Entities**: `User`, `Product`, `Order`
- **UseCases**: `GetUser`, `CreateProduct`, `UpdateOrder`
- **Repositories**: `UserRepository`, `ProductRepository`
- **Providers**: `UserProvider`, `ProductProvider`
- **Screens**: `UserScreen`, `ProductScreen`
- **Widgets**: `UserCard`, `ProductList`

## 🚀 Próximos Pasos

1. Configurar inyección de dependencias (GetIt, Provider, etc.)
2. Implementar manejo de errores global
3. Configurar logging y debugging
4. Agregar tests unitarios y de integración
5. Configurar CI/CD pipeline
