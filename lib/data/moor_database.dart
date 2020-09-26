import 'package:moor_flutter/moor_flutter.dart';

part 'moor_database.g.dart';

class Tasks extends Table {
  // autoIncrement automatically sets this to be primary key
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tagName =>
      text().nullable().customConstraint('NULL REFERENCES tags(name)')();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get completed => boolean().withDefault(Constant(false))();
}

@UseMoor(tables: [Tasks, Tags], daos: [TaskDAO, TagDAO])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: 'db.sqlite', logStatements: true));

  @override
  int get schemaVersion => 1;
}

@UseDao(tables: [
  Tasks
], queries: {
  'completedTasksGenerated':
      'SELECT * FROM tasks WHERE completed = 1 ORDER BY due_date DESC, name;'
})
class TaskDAO extends DatabaseAccessor<AppDatabase> with _$TaskDAOMixin {
  final AppDatabase db;

  TaskDAO(this.db) : super(db);

// Get/Watch task

  Future<List<Task>> getAllTasks() => select(tasks).get();

  Stream<List<Task>> watchAllTasks() {
    return (select(tasks)
          ..orderBy([
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  Stream<List<Task>> watchCompletedTasks() {
    return (select(tasks)
          ..orderBy([
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.name),
          ])
          ..where((t) => t.completed.equals(true)))
        .watch();
  }

  // Stream<List<Task>> watchCompletedTasksCustom() {
  //   return customSelectStream(
  //       'SELECT * FROM tasks WHERE completed = 1 ORDER BY due_date DESC, name;',
  //       readsFrom: {tasks}).map((rows) {
  //     return rows.map((row) => Task.fromData(row.data, db)).toList();
  //   });
  // }

// CRUD

  Future insertTask(Insertable<Task> task) => into(tasks).insert(task);
  Future updateTask(Insertable<Task> task) => update(tasks).replace(task);
  Future deleteTask(Insertable<Task> task) => delete(tasks).delete(task);
}

class Tags extends Table {
  TextColumn get name => text().withLength(min: 1, max: 10)();
  IntColumn get color => integer()();

  @override
  Set<Column> get primaryKey => {name};
}

@UseDao(tables: [Tags])
class TagDAO extends DatabaseAccessor<AppDatabase> with _$TagDAOMixin {
  final AppDatabase db;

  TagDAO(this.db) : super(db);

  Stream<List<Tag>> watchTags() => select(tags).watch();

  Future insertTag(Insertable<Tag> tag) => into(tags).insert(tag);
}
