import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/moor_database.dart';
import 'ui/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final db = AppDatabase();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => db.taskDAO),
        Provider(create: (_) => db.tagDAO),
      ],
      child: MaterialApp(
        title: 'Material App',
        home: HomePage(),
      ),
    );
  }
}
