import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/bank_account_remote_datasource.dart';
import '../../data/datasources/client_remote_datasource.dart';
import '../../data/datasources/company_remote_datasource.dart';
import '../../data/datasources/factura_remote_datasource.dart';
import '../../data/local/todo_database.dart';
import '../../data/repositories/bank_account_repository_impl.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../data/repositories/factura_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/bank_account_repository.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/repositories/company_repository.dart';
import '../../domain/repositories/factura_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_bank_accounts.dart';
import '../../domain/usecases/get_clients.dart';
import '../../domain/usecases/get_companies.dart';
import '../../domain/usecases/get_facturas_by_cliente.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';

/// Provider para la base de datos
/// Singleton que se crea una sola vez y se reutiliza
final databaseProvider = Provider<TodoDatabase>((ref) {
  return TodoDatabase();
});

/// Provider para el repositorio de tareas
/// Depende de la base de datos
final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TaskRepositoryImpl(database);
});

/// Provider para el caso de uso GetTasks
final getTasksProvider = Provider<GetTasks>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTasks(repository);
});

/// Provider para el caso de uso GetCompletedTasks
final getCompletedTasksProvider = Provider<GetCompletedTasks>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetCompletedTasks(repository);
});

/// Provider para el caso de uso GetPendingTasks
final getPendingTasksProvider = Provider<GetPendingTasks>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetPendingTasks(repository);
});

/// Provider para el caso de uso GetTaskById
final getTaskByIdProvider = Provider<GetTaskById>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTaskById(repository);
});

/// Provider para el caso de uso SearchTasks
final searchTasksProvider = Provider<SearchTasks>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return SearchTasks(repository);
});

/// Provider para el caso de uso AddTask
final addTaskProvider = Provider<AddTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return AddTask(repository);
});

/// Provider para el caso de uso AddMultipleTasks
final addMultipleTasksProvider = Provider<AddMultipleTasks>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return AddMultipleTasks(repository);
});

/// Provider para el caso de uso UpdateTask
final updateTaskProvider = Provider<UpdateTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return UpdateTask(repository);
});

/// Provider para el caso de uso MarkTaskAsCompleted
final markTaskAsCompletedProvider = Provider<MarkTaskAsCompleted>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return MarkTaskAsCompleted(repository);
});

/// Provider para el caso de uso MarkTaskAsPending
final markTaskAsPendingProvider = Provider<MarkTaskAsPending>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return MarkTaskAsPending(repository);
});

/// Provider para el caso de uso DeleteTask
final deleteTaskProvider = Provider<DeleteTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return DeleteTask(repository);
});

/// Provider para el caso de uso DeleteCompletedTasks
final deleteCompletedTasksProvider = Provider<DeleteCompletedTasks>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return DeleteCompletedTasks(repository);
});

/// Provider para el caso de uso DeleteAllTasks
final deleteAllTasksProvider = Provider<DeleteAllTasks>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return DeleteAllTasks(repository);
});

/// Provider para el caso de uso DeleteTasksByCriteria
final deleteTasksByCriteriaProvider = Provider<DeleteTasksByCriteria>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return DeleteTasksByCriteria(repository);
});

// ========== Providers para Compañías ==========

/// Provider para el datasource remoto de compañías
final companyRemoteDataSourceProvider =
    Provider<ICompanyRemoteDataSource>((ref) {
  return CompanyRemoteDataSource();
});

/// Provider para el repositorio de compañías
final companyRepositoryProvider = Provider<ICompanyRepository>((ref) {
  final remoteDataSource = ref.watch(companyRemoteDataSourceProvider);
  return CompanyRepositoryImpl(remoteDataSource);
});

/// Provider para el caso de uso GetCompanies
final getCompaniesProvider = Provider<GetCompanies>((ref) {
  final repository = ref.watch(companyRepositoryProvider);
  return GetCompanies(repository);
});

// ========== Providers para Cuentas Bancarias ==========

/// Provider para el datasource remoto de cuentas bancarias
final bankAccountRemoteDataSourceProvider =
    Provider<IBankAccountRemoteDataSource>((ref) {
  return BankAccountRemoteDataSource();
});

/// Provider para el repositorio de cuentas bancarias
final bankAccountRepositoryProvider = Provider<IBankAccountRepository>((ref) {
  final remoteDataSource = ref.watch(bankAccountRemoteDataSourceProvider);
  return BankAccountRepositoryImpl(remoteDataSource);
});

/// Provider para el caso de uso GetBankAccounts
final getBankAccountsProvider = Provider<GetBankAccounts>((ref) {
  final repository = ref.watch(bankAccountRepositoryProvider);
  return GetBankAccounts(repository);
});

// ========== Providers para Clientes ==========

/// Provider para el datasource remoto de clientes
final clientRemoteDataSourceProvider =
    Provider<IClientRemoteDataSource>((ref) {
  return ClientRemoteDataSource();
});

/// Provider para el repositorio de clientes
final clientRepositoryProvider = Provider<IClientRepository>((ref) {
  final remoteDataSource = ref.watch(clientRemoteDataSourceProvider);
  return ClientRepositoryImpl(remoteDataSource);
});

/// Provider para el caso de uso GetClients
final getClientsProvider = Provider<GetClients>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return GetClients(repository);
});

// ========== Providers para Facturas ==========

/// Provider para el datasource remoto de facturas
final facturaRemoteDataSourceProvider =
    Provider<IFacturaRemoteDataSource>((ref) {
  return FacturaRemoteDataSource();
});

/// Provider para el repositorio de facturas
final facturaRepositoryProvider = Provider<IFacturaRepository>((ref) {
  final remoteDataSource = ref.watch(facturaRemoteDataSourceProvider);
  return FacturaRepositoryImpl(remoteDataSource);
});

/// Provider para el caso de uso GetFacturasByCliente
final getFacturasByClienteProvider = Provider<GetFacturasByCliente>((ref) {
  final repository = ref.watch(facturaRepositoryProvider);
  return GetFacturasByCliente(repository);
});
