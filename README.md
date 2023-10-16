### Drop Down Date Picker

Allow quick setting of dates by choosing what date options you would like to set

```dart
enum DateOptions { d, m, y }
```


Set an initial date to give the user a hint
If left the initial date will be the current date

```dart
    class _MyHomePageState extends State<MyHomePage> {
  ValueNotifier<DateTime> dateNotifier =
  ValueNotifier(DateTime(2020, MonthsOfYear.march.number, 12));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: ValueListenableBuilder(
        valueListenable: dateNotifier,
        builder: (context, date, _) {
          return Center(
            child: Column(
              children: [
                Text("${date.day} - ${date.month} - ${date.year}"),
                DropDownDatePicker(
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
        },), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

```

* BoxConstrains have been set on the calendar to give it a fixed size as recommended.
* The values can be initialized as **double.infinite** when you want an expanded view

* The **dateOptions** parameter is used to order your date, such as a date format, and also choose what you'd like to be able to change

* The **onDateChanged** function is a callback used to get the new date.