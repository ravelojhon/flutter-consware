import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app_consware/src/core/errors/failures.dart';
import 'package:app_consware/src/domain/entities/task.dart';
import 'package:app_consware/src/domain/repositories/task_repository.dart';
import 'package:app_consware/src/domain/usecases/add_task.dart';

import 'add_task_test.mocks.dart';

@GenerateMocks([ITaskRepository])
void main() {
  late AddTask usecase;
  late MockITaskRepository mockRepository;

  setUp(() {
    mockRepository = MockITaskRepository();
    usecase = AddTask(mockRepository);
  });

  group('AddTask', () {
    const testTitle = 'Test Task';
    const testId = 1;
    final testTask = Task.create(title: testTitle);
    final testTaskWithId = testTask.copyWith(id: testId);

    test('should return Task when repository call is successful', () async {
      // Arrange
      when(
        mockRepository.createTask(any),
      ).thenAnswer((_) async => dartz.Right(testTaskWithId));

      // Act
      final result = await usecase.call(title: testTitle);

      // Assert
      expect(result, dartz.Right(testTaskWithId));
      verify(mockRepository.createTask(any));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when title is empty', () async {
      // Act
      final result = await usecase.call(title: '');

      // Assert
      expect(
        result,
        dartz.Left(
          const ValidationFailure(
            message: 'El título de la tarea no puede estar vacío',
            code: 'EMPTY_TITLE',
          ),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when title is too long', () async {
      // Arrange
      final longTitle = 'a' * 256;

      // Act
      final result = await usecase.call(title: longTitle);

      // Assert
      expect(
        result,
        dartz.Left(
          const ValidationFailure(
            message: 'El título de la tarea no puede exceder 255 caracteres',
            code: 'TITLE_TOO_LONG',
          ),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should trim title before creating task', () async {
      // Arrange
      const titleWithSpaces = '  Test Task  ';
      when(
        mockRepository.createTask(any),
      ).thenAnswer((_) async => dartz.Right(testTaskWithId));

      // Act
      await usecase.call(title: titleWithSpaces);

      // Assert
      verify(
        mockRepository.createTask(
          argThat(predicate<Task>((task) => task.title == 'Test Task')),
        ),
      );
    });

    test('should propagate repository failure', () async {
      // Arrange
      const failure = ServerFailure(
        message: 'Database error',
        code: 'DB_ERROR',
      );
      when(
        mockRepository.createTask(any),
      ).thenAnswer((_) async => dartz.Left(failure));

      // Act
      final result = await usecase.call(title: testTitle);

      // Assert
      expect(result, dartz.Left(failure));
      verify(mockRepository.createTask(any));
    });

    test('should create task with isCompleted false by default', () async {
      // Arrange
      when(
        mockRepository.createTask(any),
      ).thenAnswer((_) async => dartz.Right(testTaskWithId));

      // Act
      await usecase.call(title: testTitle);

      // Assert
      verify(
        mockRepository.createTask(
          argThat(predicate<Task>((task) => !task.isCompleted)),
        ),
      );
    });

    test('should create task with specified isCompleted status', () async {
      // Arrange
      when(
        mockRepository.createTask(any),
      ).thenAnswer((_) async => dartz.Right(testTaskWithId));

      // Act
      await usecase.call(title: testTitle, isCompleted: true);

      // Assert
      verify(
        mockRepository.createTask(
          argThat(predicate<Task>((task) => task.isCompleted)),
        ),
      );
    });
  });

  group('AddMultipleTasks', () {
    late AddMultipleTasks usecase;

    setUp(() {
      usecase = AddMultipleTasks(mockRepository);
    });

    test(
      'should return list of tasks when all tasks are created successfully',
      () async {
        // Arrange
        const titles = ['Task 1', 'Task 2', 'Task 3'];
        final tasks = titles
            .asMap()
            .entries
            .map(
              (entry) =>
                  Task.create(title: entry.value).copyWith(id: entry.key + 1),
            )
            .toList();

        when(
          mockRepository.createTask(any),
        ).thenAnswer((_) async => dartz.Right(tasks.first));

        // Act
        final result = await usecase.call(titles);

        // Assert
        expect(result.isRight(), true);
        verify(mockRepository.createTask(any)).called(titles.length);
      },
    );

    test('should return ValidationFailure when list is empty', () async {
      // Act
      final result = await usecase.call([]);

      // Assert
      expect(
        result,
        dartz.Left(
          const ValidationFailure(
            message: 'La lista de tareas no puede estar vacía',
            code: 'EMPTY_TASK_LIST',
          ),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return first failure when any task creation fails', () async {
      // Arrange
      const titles = ['Task 1', 'Task 2'];
      const failure = ServerFailure(
        message: 'Database error',
        code: 'DB_ERROR',
      );

      when(
        mockRepository.createTask(any),
      ).thenAnswer((_) async => dartz.Left(failure));

      // Act
      final result = await usecase.call(titles);

      // Assert
      expect(result, dartz.Left(failure));
      verify(mockRepository.createTask(any)).called(titles.length);
    });
  });

  group('ValidateTaskData', () {
    test('should return Right for valid title', () {
      // Act
      final result = ValidateTaskData.validateTitle('Valid Title');

      // Assert
      expect(result, dartz.Right('Valid Title'));
    });

    test('should return Left for empty title', () {
      // Act
      final result = ValidateTaskData.validateTitle('');

      // Assert
      expect(
        result,
        dartz.Left(
          const ValidationFailure(
            message: 'El título de la tarea no puede estar vacío',
            code: 'EMPTY_TITLE',
          ),
        ),
      );
    });

    test('should return Left for title that is too long', () {
      // Arrange
      final longTitle = 'a' * 256;

      // Act
      final result = ValidateTaskData.validateTitle(longTitle);

      // Assert
      expect(
        result,
        dartz.Left(
          const ValidationFailure(
            message: 'El título de la tarea no puede exceder 255 caracteres',
            code: 'TITLE_TOO_LONG',
          ),
        ),
      );
    });

    test('should return Right for valid task', () {
      // Arrange
      final task = Task.create(title: 'Valid Title');

      // Act
      final result = ValidateTaskData.validateTask(task);

      // Assert
      expect(result, dartz.Right(task));
    });

    test('should return Left for task with future creation date', () {
      // Arrange
      final task = Task.create(
        title: 'Valid Title',
      ).copyWith(createdAt: DateTime.now().add(const Duration(days: 1)));

      // Act
      final result = ValidateTaskData.validateTask(task);

      // Assert
      expect(
        result,
        dartz.Left(
          const ValidationFailure(
            message: 'La fecha de creación no puede ser futura',
            code: 'INVALID_CREATION_DATE',
          ),
        ),
      );
    });

    test('should return Left for task with invalid update date', () {
      // Arrange
      final now = DateTime.now();
      final task = Task.create(title: 'Valid Title').copyWith(
        createdAt: now,
        updatedAt: now.subtract(const Duration(days: 1)),
      );

      // Act
      final result = ValidateTaskData.validateTask(task);

      // Assert
      expect(
        result,
        dartz.Left(
          const ValidationFailure(
            message:
                'La fecha de actualización no puede ser anterior a la creación',
            code: 'INVALID_UPDATE_DATE',
          ),
        ),
      );
    });
  });
}
