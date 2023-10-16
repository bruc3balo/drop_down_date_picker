import 'package:spinner_date_picker/date_picker/date_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Picker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Date Picker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ValueNotifier<DateTime> dateNotifier = ValueNotifier(
    DateTime(2020, MonthsOfYear.march.number, 12),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ValueListenableBuilder(
          valueListenable: dateNotifier,
          builder: (context, date, _) {
            return Center(
              child: Column(
                children: [
                  Text("${date.day} - ${date.month} - ${date.year}"),
                  SpinnerDatePicker(
                    initialDate: date,
                    constraints: const BoxConstraints(
                      minHeight: 400,
                      minWidth: 400,
                      maxHeight: 400,
                      maxWidth: double.infinity,
                    ),
                    dateOptions: const [
                      DateOptions.d,
                      DateOptions.m,
                      DateOptions.y
                    ],
                    onDateChanged: (date) => dateNotifier.value = date,
                  ),
                ],
              ),
            );
          }), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
