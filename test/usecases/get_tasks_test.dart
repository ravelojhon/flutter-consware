import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app_consware/src/core/errors/failures.dart';
import 'package:app_consware/src/domain/entities/task.dart';
import 'package:app_consware/src/domain/repositories/task_repository.dart';
import 'package:app_consware/src/domain/usecases/get_tasks.dart';

import 'get_tasks_test.mocks.dart';

@GenerateMocks([ITaskRepository])
void main() {
  late GetTasks getTasksUseCase;
  late GetCompletedTasks getCompletedTasksUseCase;
  late GetPendingTasks getPendingTasksUseCase;
  late GetTaskById getTaskByIdUseCase;
  late SearchTasks searchTasksUseCase;
  late MockITaskRepository mockRepository;

  setUp(() {
    mockRepository = MockITaskRepository();
    getTasksUseCase = GetTasks(mockRepository);
    getCompletedTasksUseCase = GetCompletedTasks(mockRepository);
    getPendingTasksUseCase = GetPendingTasks(mockRepository);
    getTaskByIdUseCase = GetTaskById(mockRepository);
    searchTasksUseCase = SearchTasks(mockRepository);
  });

  group('GetTasks', () {
    test(
      'should return list of tasks when repository call is successful',
      () async {
        // Arrange
        final tasks = [
          Task.create(title: 'Task 1').copyWith(id: 1),
          Task.create(title: 'Task 2').copyWith(id: 2),
        ];
        when(
          mockRepository.getAllTasksOrderedByUpdated(),
        ).thenAnswer((_) async => dartz.Right(tasks));

        // Act
        final result = await getTasksUseCase.call();

        // Assert
        expect(result, dartz.Right(tasks));
        verify(mockRepository.getAllTasksOrderedByUpdated());
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should propagate repository failure', () async {
      // Arrange
      const failure = ServerFailure(
        message: 'Database error',
        code: 'DB_ERROR',
      );
      when(
        mockRepository.getAllTasksOrderedByUpdated(),
      ).thenAnswer((_) async => dartz.Left(failure));

      // Act
      final result = await getTasksUseCase.call();

      // Assert
      expect(result, dartz.Left(failure));
      verify(mockRepository.getAllTasksOrderedByUpdated());
    });
  });

  group('GetCompletedTasks', () {
    test(
      'should return list of completed tasks when repository call is successful',
      () async {
        // Arrange
        final completedTasks = [
          Task.create(
            title: 'Completed Task 1',
            isCompleted: true,
          ).copyWith(id: 1),
          Task.create(
            title: 'Completed Task 2',
            isCompleted: true,
          ).copyWith(id: 2),
        ];
        when(
          mockRepository.getCompletedTasks(),
        ).thenAnswer((_) async => dartz.Right(completedTasks));

        // Act
        final result = await getCompletedTasksUseCase.call();

        // Assert
        expect(result, dartz.Right(completedTasks));
        verify(mockRepository.getCompletedTasks());
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should propagate repository failure', () async {
      // Arrange
      const failure = ServerFailure(
        message: 'Database error',
        code: 'DB_ERROR',
      );
      when(
        mockRepository.getCompletedTasks(),
      ).thenAnswer((_) async => dartz.Left(failure));

      // Act
      final result = await getCompletedTasksUseCase.call();

      // Assert
      expect(result, dartz.Left(failure));
      verify(mockRepository.getCompletedTasks());
    });
  });

  group('GetPendingTasks', () {
    test(
      'should return list of pending tasks when repository call is successful',
      () async {
        // Arrange
        final pendingTasks = [
          Task.create(
            title: 'Pending Task 1',
            isCompleted: false,
          ).copyWith(id: 1),
          Task.create(
            title: 'Pending Task 2',
            isCompleted: false,
          ).copyWith(id: 2),
        ];
        when(
          mockRepository.getPendingTasks(),
        ).thenAnswer((_) async => dartz.Right(pendingTasks));

        // Act
        final result = await getPendingTasksUseCase.call();

        // Assert
        expect(result, dartz.Right(pendingTasks));
        verify(mockRepository.getPendingTasks());
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should propagate repository failure', () async {
      // Arrange
      const failure = ServerFailure(
        message: 'Database error',
        code: 'DB_ERROR',
      );
      when(
        mockRepository.getPendingTasks(),
      ).thenAnswer((_) async => dartz.Left(failure));

      // Act
      final result = await getPendingTasksUseCase.call();

      // Assert
      expect(result, dartz.Left(failure));
      verify(mockRepository.getPendingTasks());
    });
  });

  group('GetTaskById', () {
    const testId = 1;
    final testTask = Task.create(title: 'Test Task').copyWith(id: testId);

    test('should return task when repository call is successful', () async {
      // Arrange
      when(
        mockRepository.getTaskById(testId),
      ).thenAnswer((_) async => dartz.Right(testTask));

      // Act
      final result = await getTaskByIdUseCase.call(testId);

      // Assert
      expect(result, dartz.Right(testTask));
      verify(mockRepository.getTaskById(testId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when id is zero', () async {
      // Act
      final result = await getTaskByIdUseCase.call(0);

      // Assert
      expect(
        result,
        dartz.Left(
          const ValidationFailure(
            message: 'El ID debe ser mayor a 0',
            code: 'INVALID_ID',
          ),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when id is negative', () async {
      // Act
      final result = await getTaskByIdUseCase.call(-1);

      // Assert
      expect(
        result,
        dartz.Left(
          const ValidationFailure(
            message: 'El ID debe ser mayor a 0',
            code: 'INVALID_ID',
          ),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return null task when task is not found', () async {
      // Arrange
      when(
        mockRepository.getTaskById(testId),
      ).thenAnswer((_) async => dartz.Right(null));

      // Act
      final result = await getTaskByIdUseCase.call(testId);

      // Assert
      expect(result, dartz.Right(null));
      verify(mockRepository.getTaskById(testId));
    });

    test('should propagate repository failure', () async {
      // Arrange
      const failure = ServerFailure(
        message: 'Database error',
        code: 'DB_ERROR',
      );
      when(
        mockRepository.getTaskById(testId),
      ).thenAnswer((_) async => dartz.Left(failure));

      // Act
      final result = await getTaskByIdUseCase.call(testId);

      // Assert
      expect(result, dartz.Left(failure));
      verify(mockRepository.getTaskById(testId));
    });
  });

  group('SearchTasks', () {
    const testQuery = 'test';
    final searchResults = [
      Task.create(title: 'Test Task 1').copyWith(id: 1),
      Task.create(title: 'Test Task 2').copyWith(id: 2),
    ];

    test(
      'should return search results when repository call is successful',
      () async {
        // Arrange
        when(
          mockRepository.searchTasksByTitle(testQuery),
        ).thenAnswer((_) async => dartz.Right(searchResults));

        // Act
        final result = await searchTasksUseCase.call(testQuery);

        // Assert
        expect(result, dartz.Right(searchResults));
        verify(mockRepository.searchTasksByTitle(testQuery));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return ValidationFailure when query is empty', () async {
      // Act
      final result = await searchTasksUseCase.call('');

      // Assert
      expect(
        result,
        dartz.Left(
          const ValidationFailure(
            message: 'La consulta de búsqueda no puede estar vacía',
            code: 'EMPTY_SEARCH_QUERY',
          ),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test(
      'should return ValidationFailure when query is only whitespace',
      () async {
        // Act
        final result = await searchTasksUseCase.call('   ');

        // Assert
        expect(
          result,
          dartz.Left(
            const ValidationFailure(
              message: 'La consulta de búsqueda no puede estar vacía',
              code: 'EMPTY_SEARCH_QUERY',
            ),
          ),
        );
        verifyZeroInteractions(mockRepository);
      },
    );

    test('should return empty list when no tasks match search', () async {
      // Arrange
      when(
        mockRepository.searchTasksByTitle(testQuery),
      ).thenAnswer((_) async => dartz.Right([]));

      // Act
      final result = await searchTasksUseCase.call(testQuery);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure'),
        (tasks) => expect(tasks, isEmpty),
      );
      verify(mockRepository.searchTasksByTitle(testQuery));
    });

    test('should propagate repository failure', () async {
      // Arrange
      const failure = ServerFailure(
        message: 'Database error',
        code: 'DB_ERROR',
      );
      when(
        mockRepository.searchTasksByTitle(testQuery),
      ).thenAnswer((_) async => dartz.Left(failure));

      // Act
      final result = await searchTasksUseCase.call(testQuery);

      // Assert
      expect(result, dartz.Left(failure));
      verify(mockRepository.searchTasksByTitle(testQuery));
    });
  });
}
