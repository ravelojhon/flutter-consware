import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/task_list_notifier.dart';
import '../../domain/entities/task.dart';
import '../widgets/improved_task_item.dart';
import '../widgets/error_modal.dart';
import '../../core/ui/feedback_service.dart';
import '../../core/ui/confirmation_service.dart';
import '../../core/ui/error_widget.dart';
import 'simple_add_edit_task_screen.dart';

/// Pantalla mejorada para mostrar la lista de tareas
/// Con diseño más atractivo y funcionalidad completa de edición
class ImprovedTaskListScreen extends ConsumerStatefulWidget {
  const ImprovedTaskListScreen({super.key});

  @override
  ConsumerState<ImprovedTaskListScreen> createState() =>
      _ImprovedTaskListScreenState();
}

class _ImprovedTaskListScreenState
    extends ConsumerState<ImprovedTaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'all'; // 'all', 'completed', 'pending'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskListState = ref.watch(taskListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Header fijo con título y acciones
          _buildFixedAppBar(context),

          // Sección de búsqueda y filtros fija
          _buildFixedSearchAndFiltersSection(),

          // Sección de estadísticas fija
          _buildFixedStatsSection(taskListState),

          // Lista scrolleable de tareas
          Expanded(child: _buildTaskList(taskListState)),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// Construir App Bar fijo con título y acciones
  Widget _buildFixedAppBar(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120, maxHeight: 160),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Icon(
                        Icons.task_alt,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        'Mis Tareas',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(taskListProvider.notifier).refresh();
                    },
                    tooltip: 'Actualizar',
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) => _handleMenuAction(value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'clear_completed',
                        child: ListTile(
                          leading: Icon(Icons.clear_all),
                          title: Text('Limpiar completadas'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'reset_filter',
                        child: ListTile(
                          leading: Icon(Icons.clear_all),
                          title: Text('Limpiar filtros'),
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Manejar acciones del menú
  void _handleMenuAction(String action) {
    HapticFeedback.lightImpact();
    switch (action) {
      case 'clear_completed':
        _showClearCompletedDialog();
        break;
      case 'reset_filter':
        _resetFilters();
        break;
    }
  }

  /// Mostrar diálogo para limpiar tareas completadas
  Future<void> _showClearCompletedDialog() async {
    final taskListState = ref.read(taskListProvider);
    final completedCount = taskListState.when(
      data: (tasks) => tasks.where((t) => t.isCompleted).length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    if (completedCount == 0) {
      FeedbackService.showInfo(
        context,
        message: 'No hay tareas completadas para eliminar.',
      );
      return;
    }

    final confirmed = await ConfirmationService.showClearCompletedConfirmation(
      context,
      count: completedCount,
    );

    if (confirmed) {
      try {
        await ref.read(taskListProvider.notifier).deleteCompletedTasks();
        FeedbackService.showSuccess(
          context,
          message: 'Se eliminaron $completedCount tareas completadas.',
        );
      } catch (e) {
        FeedbackService.showError(
          context,
          message: 'No se pudieron eliminar las tareas completadas.',
        );
      }
    }
  }

  /// Resetear filtros
  void _resetFilters() {
    setState(() {
      _filterStatus = 'all';
      _searchQuery = '';
      _searchController.clear();
    });
  }

  /// Construir sección fija de estadísticas
  Widget _buildFixedStatsSection(AsyncValue<List<Task>> taskListState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: taskListState.when(
        data: (tasks) => _buildStatsContent(tasks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error),
      ),
    );
  }

  /// Construir sección fija de búsqueda y filtros
  Widget _buildFixedSearchAndFiltersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Campo de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar tareas...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Filtros con dropdown
          Row(
            children: [
              const Icon(Icons.filter_list, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Filtrar por estado:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterStatus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.list, size: 16),
                          SizedBox(width: 8),
                          Text('Todas'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text('Completadas'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'pending',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pending, size: 16, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Pendientes'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    HapticFeedback.lightImpact(); // Agregar vibración
                    setState(() {
                      _filterStatus = value ?? 'all';
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construir contenido de estadísticas
  Widget _buildStatsContent(List<Task> tasks) {
    final completed = tasks.where((t) => t.isCompleted).length;
    final pending = tasks.length - completed;
    final percentage = tasks.isEmpty ? 0.0 : (completed / tasks.length) * 100;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard(
              'Total',
              tasks.length.toString(),
              Icons.list_alt,
              Colors.blue,
            ),
            _buildStatCard(
              'Completadas',
              completed.toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Pendientes',
              pending.toString(),
              Icons.pending,
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildProgressBar(percentage),
      ],
    );
  }

  /// Construir tarjeta de estadística
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  /// Construir barra de progreso
  Widget _buildProgressBar(double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage == 100 ? Colors.green : Theme.of(context).primaryColor,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// Construir lista de tareas
  Widget _buildTaskList(AsyncValue<List<Task>> taskListState) {
    return taskListState.when(
      data: (tasks) {
        final filteredTasks = _filterTasks(tasks);

        if (filteredTasks.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            ref.read(taskListProvider.notifier).refresh();
          },
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              8,
              8,
              8,
              filteredTasks.length <= 3
                  ? 8
                  : 100, // Margin solo si hay muchas tareas
            ),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return ImprovedTaskItem(
                key: ValueKey('task_item_${task.id}'),
                task: task,
                onTap: null, // No permitir tap en toda la tarea
                onEdit: () {
                  HapticFeedback.lightImpact();
                  _editTask(context, task);
                },
                onToggleCompleted: (completed) {
                  HapticFeedback.lightImpact();
                  _toggleTaskCompletion(task);
                },
                onDelete: () {
                  HapticFeedback.lightImpact();
                  _deleteTask(task);
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }

  /// Construir estado vacío
  Widget _buildEmptyState() {
    return Container(
      height: 400, // Altura fija para evitar overflow
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.task_alt,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron tareas'
                  : 'No hay tareas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'Intenta con otros términos de búsqueda'
                    : 'Toca el botón + para agregar tu primera tarea',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _addTask(context),
                icon: const Icon(Icons.add),
                label: const Text('Agregar Primera Tarea'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Construir widget de error
  Widget _buildErrorWidget(Object error) {
    return Container(
      height: 300, // Altura fija para evitar overflow
      child: AppErrorWidget(
        error: error,
        title: 'Error al cargar las tareas',
        onRetry: () => ref.read(taskListProvider.notifier).refresh(),
      ),
    );
  }

  /// Construir botón flotante
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _addTask(context),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Nueva Tarea', style: TextStyle(color: Colors.white)),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  /// Filtrar tareas según búsqueda y filtros
  List<Task> _filterTasks(List<Task> tasks) {
    var filtered = tasks;

    // Filtrar por búsqueda primero
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        final titleMatch = task.title.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final descriptionMatch =
            task.description?.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ??
            false;
        return titleMatch || descriptionMatch;
      }).toList();
    }

    // Filtrar por estado
    if (_filterStatus == 'completed') {
      filtered = filtered.where((task) => task.isCompleted).toList();
    } else if (_filterStatus == 'pending') {
      filtered = filtered.where((task) => !task.isCompleted).toList();
    }

    // Solo ordenar si hay filtros activos, de lo contrario mantener el orden original
    if (_searchQuery.isNotEmpty || _filterStatus != 'all') {
      // Ordenar por fecha de actualización (más recientes primero)
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    return filtered;
  }

  /// Agregar nueva tarea
  void _addTask(BuildContext context) {
    HapticFeedback.lightImpact();
    // Perder el focus del campo de búsqueda antes de navegar
    FocusScope.of(context).unfocus();
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (context) => const SimpleAddEditTaskScreen()),
    );
  }

  /// Editar tarea existente
  void _editTask(BuildContext context, Task task) {
    HapticFeedback.lightImpact();
    // Perder el focus del campo de búsqueda antes de navegar
    FocusScope.of(context).unfocus();
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => SimpleAddEditTaskScreen(task: task),
      ),
    );
  }

  /// Alternar estado de completado de una tarea
  void _toggleTaskCompletion(Task task) {
    try {
      ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
    } catch (e) {
      ErrorModal.show(
        context,
        title: 'Error al actualizar tarea',
        message: 'No se pudo cambiar el estado de la tarea: ${e.toString()}',
      );
    }
  }

  /// Eliminar una tarea
  Future<void> _deleteTask(Task task) async {
    try {
      await ref.read(taskListProvider.notifier).deleteTask(task.id);
      FeedbackService.showSuccess(
        context,
        message: 'Tarea "${task.title}" eliminada correctamente.',
      );
    } catch (e) {
      FeedbackService.showError(
        context,
        message: 'No se pudo eliminar la tarea.',
      );
    }
  }
}
